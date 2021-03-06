#
# Cookbook Name:: aixtest
# Recipe:: default
#
# Copyright (C) 2014 Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

%w(unzip less bash).each do |pkg|
  aix_toolboxpackage pkg do
    action :install
  end
end

aix_inittab 'webserverstart' do
  action :remove
end

# Replaced by direct support in chef-client cookbook, but
# here's an illustration of a custom command for the inittab

#aix_inittab 'chef' do
#  runlevel '2'
#  processaction 'once'
#  command '/opt/chef/bin/chef-client -d > /dev/console 2>&1'
#  action :install
#end

%w(inetd snmpd hostmibd snmpmibd aixmibd writesrv qdaemon).each do |tcpsrv|
  aix_tcpservice tcpsrv do
    immediate true
    action :disable
  end
end

aix_tcpservice 'xntpd' do
  immediate true
  action :enable
end

aix_subserver 'telnet' do
  protocol 'tcp'
  action :disable
end

aix_subserver 'ftp' do
  protocol 'tcp'
  action :disable
end

# Disable root logins - must su
execute 'chuser login=false root' do
  only_if 'lsuser -a login root | grep true'
  not_if { node['virtualization']['wpar_no'] }
  action :run
end
