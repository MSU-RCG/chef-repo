#
# Cookbook Name:: munin
# Recipe:: server
#
# Copyright 2010-2011, Opscode, Inc.
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
#

include_recipe "apache2"
include_recipe "apache2::mod_auth_openid"
include_recipe "apache2::mod_rewrite"
include_recipe "munin::client"

package "munin"

web_users = search( :users, "munin_admin:true" )
#munin_servers = search(:node, "munin:[* TO *] AND role:#{node[:app_environment]}")
munin_nodes = search(:node, "munin:[* TO *]")
# Fetch all the snmp_nodes from the data bag item
snmp_nodes = search( :monitoring, "hosts:[* TO *]" ).first['hosts']

case node[:platform]
when "arch"
  cron "munin-graph-html" do
    command "/usr/bin/munin-cron"
    user "munin"
    minute "*/5"
  end
else
  cookbook_file "/etc/cron.d/munin" do
    source "munin-cron"
    mode "0644"
    owner "root"
    group "root"
    backup 0
  end
end



if node[:public_domain]
  case node[:app_environment]
  when "production"
    public_domain = node[:public_domain]
  else
    public_domain = "#{node[:app_environment]}.#{node[:public_domain]}"
  end
else
  public_domain = node[:domain]
end

template "/etc/munin/munin.conf" do
  source "munin.conf.erb"
  mode 0644
  variables(:munin_nodes => munin_nodes, :munin_snmp_nodes => snmp_nodes)
end

apache_site "000-default" do
  enable false
end

template "#{node[:apache][:dir]}/sites-available/munin.conf" do
  source "apache2.conf.erb"
  mode 0644
  variables :public_domain => public_domain
  if ::File.symlink?("#{node[:apache][:dir]}/sites-enabled/munin.conf")
    notifies :reload, resources(:service => "apache2")
  end
end

directory node['munin']['docroot'] do
  owner "munin"
  group "munin"
  mode 0755
end

template "#{node[:munin][:dir]}/htpasswd.users" do
  source "htpasswd.users.erb"
  owner "munin"
  group node[:apache][:user]
  mode 0640
  variables(
    :sysadmins => web_users
  )
end

# ---- snmp hosts setup ----

# Grab the defaults for snmp
snmp_defaults = data_bag_item( "snmp", "settings" )

# Filled in hosts
snmp_hosts = Hash.new

# Fill in the values with defaults for the template
snmp_nodes.each do |host,settings|
  snmp_hosts[host] = Hash.new
  settings.each do |k,v|
    if v.nil? || v.empty?
      snmp_hosts[host][k] = snmp_defaults[k]
    else
      snmp_hosts[host][k] = v
    end
  end
end

template "#{node[:munin][:dir]}/plugin-conf.d/snmp_communities" do
  source "snmp_communities.erb"
  owner "munin"
  group node[:apache][:user]
  mode 0640
  variables(
    :nodes => snmp_hosts
  )
end

snmp_nodes.each do |host,settings|
  if not settings['monitor'].nil?
    settings['monitor'].each do |service|
      munin_plugin "snmp__#{service}" do
        plugin "snmp_#{host}_#{service}"
        create_file true
      end
    end
  end
end

# Enable the apache site for munin
apache_site "munin.conf"
