require "spec_helper"
require "serverspec"

package = "argus-clients"
service = "radium"
config  = "/etc/radium.conf"
ra_config = "/etc/ra.conf"
user    = "argus"
group   = "argus"
ports   = [ 561, 562 ]
log_dir = "/var/log/argus"
default_user = "root"
default_group = "root"

case os[:family]
when "freebsd"
  package = "argus-clients-sasl"
  config = "/usr/local/etc/radium.conf"
  ra_config = "/usr/local/etc/ra.conf"
  log_dir = "/var/log/argus"
  default_group = "wheel"
end

describe package(package) do
  it { should be_installed }
end 

describe file(config) do
  it { should be_file }
  its(:content) { should match (/^RADIUM_DAEMON="no"$/) }
  its(:content) { should match (/^RADIUM_MONITOR_ID="localhost"$/) }
  its(:content) { should match (/^RADIUM_MAR_STATUS_INTERVAL=60$/) }
  its(:content) { should match (/^RADIUM_ARGUS_SERVER="argus:\/\/localhost:561"$/) }
  its(:content) { should match (/^RADIUM_FILTER="ip"/) }
  its(:content) { should match (/^RADIUM_USER_AUTH="foo@reallyenglish\.com\/foo@reallyenglish\.com"$/) }
  its(:content) { should match (/^RADIUM_AUTH_PASS="password"$/) }
  its(:content) { should match (/^RADIUM_ACCESS_PORT=562$/) }
  its(:content) { should match (/^RADIUM_BIND_IP="127\.0\.0\.1"/) }
  its(:content) { should match (/^RADIUM_OUTPUT_FILE="#{ Regexp.escape("/var/log/argus/radium.out") }"$/) }
  its(:content) { should match (/^RADIUM_SETUSER_ID="#{ Regexp.escape(user) }"$/) }
  its(:content) { should match (/^RADIUM_SETGROUP_ID="#{ Regexp.escape(group) }"$/) }
end

describe file(log_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

case os[:family]
when "centos"
  describe file("/etc/sysconfig/radium") do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/^radium_flags="OPTIONS="-f #{ Regexp.escape("/etc/radium.conf") }$/) }
  end
when "freebsd"
  describe file("/etc/rc.conf.d/radium") do
    it { should be_file }
    its(:content) { should match(/^radium_flags="-f #{ Regexp.escape("/usr/local/etc/radium.conf") }"$/) }
  end
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
  describe command("ra -S 127.0.0.1:#{ p } -N 1") do
    its(:stdout) { should match(/^\s+StartTime\s+Flgs\s+Proto\s+SrcAddr\s+Sport\s+Dir\s+DstAddr\s+Dport\s+TotPkts\s+TotBytes\s+State/) }
    its(:stderr) { should eq "" }
    its(:exit_status) { should eq 0 }
  end
end
