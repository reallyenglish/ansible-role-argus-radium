require "spec_helper"
require "serverspec"

package = "argus-clients"
service = "radium"
config  = "/etc/radium.conf"
user    = "argus"
group   = "argus"
ports   = [ 562 ]
log_dir = "/var/log/argus"

case os[:family]
when "freebsd"
  package = "argus-clients-sasl"
  config = "/usr/local/etc/radium.conf"
  log_dir = "/var/log/argus"
end

describe package(package) do
  it { should be_installed }
end 

describe file(config) do
  it { should be_file }
  its(:content) { should match (/RADIUM_DAEMON="no"$/) }
end

describe file(log_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

case os[:family]
when "freebsd"
  describe file("/etc/rc.conf.d/radium") do
    it { should be_file }
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
end
