#
# Author:: Joshua Sierles <joshua@37signals.com>
# Author:: Joshua Timberman <joshua@opscode.com>
# Author:: Nathan Haneysmith <nathan@opscode.com>
# Cookbook Name:: nagios
# Recipe:: server
#
# Copyright 2009, 37signals
# Copyright 2009-2010, Opscode, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe "apache2"
include_recipe "apache2::mod_ssl"
include_recipe "apache2::mod_rewrite"
include_recipe "nagios::client"

# Production Search
users = search(:users, 'nagios:[* TO *]')
# Debug Search
#users = search(:users, 'id:tyghe')
all_nodes = search(:node, "*:*")
nodes = Array.new

# Will hold the members that will become contacts
members = Array.new
sysadmins = Array.new

# Get rid of entries with blank pager & email
# I can't seem to get the search above to just include non empty values so
# a loop it is
users.each do |s|
  if not s['nagios']['email'].empty? and not s['nagios']['pager'].empty?
    Chef::Log.debug( "Adding user #{s['id']} Email: #{s['nagios']['email']} Pager: #{s['nagios']['pager']}" )
    sysadmins << s
    members << s['id']
  end
end

if all_nodes.empty?
  Chef::Log.info("No nodes returned from search, using this node so hosts.cfg has data")
  nodes << node
else
 # Get rid of duplicate names
  all_nodes.each do |a|
    can_add = true
    nodes.each do |n|
      if a['hostname'] == n['hostname']
        can_add = false
      end
    end
    if can_add and not a['hostname'].nil?
      Chef::Log.debug( "Adding #{a['hostname']} to nodes to be monitored" )
      nodes << a
    end
  end
end

role_list = Array.new
service_hosts= Hash.new
search(:role, "*:*") do |r|
  role_list << r.name
  #search(:node, "role:#{r.name} AND app_environment:#{node[:app_environment]}") do |n|
  search(:node, "role:#{r.name}") do |n|
    service_hosts[r.name] = n['hostname']
  end
end

if node[:public_domain]
  public_domain = node[:public_domain]
else
  public_domain = node[:domain]
end

%w{ nagios3 nagios-nrpe-plugin nagios-images }.each do |pkg|
  package pkg
end

service "nagios3" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable ]
end

nagios_conf "nagios" do
  config_subdir false
end

directory "#{node[:nagios][:dir]}/dist" do
  owner "nagios"
  group "nagios"
  mode "0755"
end

directory node[:nagios][:state_dir] do
  owner "nagios"
  group "nagios"
  mode "0751"
end

directory "#{node[:nagios][:state_dir]}/rw" do
  owner "nagios"
  group node[:apache][:user]
  mode "2710"
end

execute "archive default nagios object definitions" do
  command "mv #{node[:nagios][:dir]}/conf.d/*_nagios*.cfg #{node[:nagios][:dir]}/dist"
  not_if { Dir.glob(node[:nagios][:dir] + "/conf.d/*_nagios*.cfg").empty? }
end

file "#{node[:apache][:dir]}/conf.d/nagios3.conf" do
  action :delete
end

case node[:nagios][:server_auth_method]
when "openid"
  include_recipe "apache2::mod_auth_openid"
else
  template "#{node[:nagios][:dir]}/htpasswd.users" do
    source "htpasswd.users.erb"
    owner "nagios"
    group node[:apache][:user]
    mode 0640
    variables(
      :sysadmins => sysadmins
    )
  end
end

apache_site "000-default" do
  enable false
end

remote_directory "#{node[:apache][:dir]}/ssl" do
  source "ssl"
  owner "root"
  group "root"
  mode "0755"
  action :create
  files_mode "0755"
end

template "#{node[:apache][:dir]}/sites-available/nagios3.conf" do
  source "apache2.conf.erb"
  mode 0644
  variables :public_domain => public_domain
  if ::File.symlink?("#{node[:apache][:dir]}/sites-enabled/nagios3.conf")
    notifies :reload, resources(:service => "apache2")
  end
end

apache_site "nagios3.conf"

%w{ nagios cgi }.each do |conf|
  nagios_conf conf do
    config_subdir false
  end
end

%w{ commands templates timeperiods}.each do |conf|
  nagios_conf conf
end

nagios_conf "services" do
  variables :service_hosts => service_hosts
end

nagios_conf "contacts" do
  variables :admins => sysadmins, :members => members
end

nagios_conf "hostgroups" do
  variables :roles => role_list
end

nagios_conf "hosts" do
  variables :nodes => nodes
end
