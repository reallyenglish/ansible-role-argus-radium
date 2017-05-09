require "spec_helper"
require "serverspec"

package = "argus-clients"
service = "radium"
config  = "/etc/radium.conf"
ra_config = "/etc/ra.conf"
user    = "radium"
argus_user = "argus"
user_shell   = ""
user_home    = ""
group        = "argus"
ports   = [ 561, 562 ]
log_dir = "/var/log/argus"
default_user = "root"
default_group = "root"
daemonized = "no"

case os[:family]
when "redhat"
  user_home = "/var/log/argus"
  user_shell = "/sbin/nologin"
when "openbsd"
  user = "_radium"
  argus_user = "_argus"
  group = "_argus"
  default_group = "wheel"
  daemonized = "yes"
  user_home = "/nonexistent"
  user_shell = "/sbin/nologin"
when "freebsd"
  package = "argus-clients-sasl"
  config = "/usr/local/etc/radium.conf"
  ra_config = "/usr/local/etc/ra.conf"
  log_dir = "/var/log/argus"
  default_group = "wheel"
  user_home = "/var/log/argus"
  user_shell = "/usr/sbin/nologin"
end

describe package(package) do
  it { should be_installed }
end 

describe group(group) do
  it { should exist }
end

describe user(user) do
  it { should exist }
  it { should belong_to_group(group) }
  it { should belong_to_primary_group(group) }
  it { should have_home_directory(user_home) }
  it { should have_login_shell(user_shell) }
end

describe file(config) do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
  its(:content) { should match (/^RADIUM_DAEMON="#{ Regexp.escape(daemonized) }"$/) }
  its(:content) { should match (/^RADIUM_MONITOR_ID="localhost"$/) }
  its(:content) { should match (/^RADIUM_MAR_STATUS_INTERVAL=5$/) }
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
  it { should be_directory }
  it { should be_mode 775 }
  it { should be_owned_by argus_user }
  it { should be_grouped_into group }
end

case os[:family]
when "openbsd"
  describe file("/etc/rc.d/radium") do
    it { should be_file }
    it { should be_mode 755 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/^daemon="\/usr\/local\/sbin\/radium"$/) }
  end
when "redhat"
  describe file("/etc/sysconfig/radium") do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/^OPTIONS="-f #{ Regexp.escape("/etc/radium.conf") }"$/) }
  end
when "freebsd"
  describe file("/etc/rc.conf.d/radium") do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/^radium_flags="-f #{ Regexp.escape("/usr/local/etc/radium.conf") }"$/) }
  end

  describe file("/usr/local/etc/rc.d/radium") do
    it { should be_file }
    it { should be_mode 755 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
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
  describe command("ra -S 127.0.0.1:#{ p } -N 1 -M man") do
    its(:stdout) { should match(/^\s+StartTime\s+Flgs\s+Proto\s+SrcAddr\s+Sport\s+Dir\s+DstAddr\s+Dport\s+TotPkts\s+TotBytes\s+State/) }
    its(:stderr) { should eq "" }
    its(:exit_status) { should eq 0 }
  end
end
