#
# Cookbook Name:: osticket
# Recipe:: default
#
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

server_fqdn = node.fqdn

remote_file "#{Chef::Config[:file_cache_path]}/osticket_#{node[:osticket][:version]}.tar.gz" do
  checksum node[:osticket][:checksum]
  source "http://osticket.com/dl/osticket_#{node[:osticket][:version]}.tar.gz"
  mode "0644"
end

directory "#{node[:osticket][:dir]}" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

execute "untar-osticket" do
  cwd node[:osticket][:dir]
  command "tar --strip-components 2 -xzf #{Chef::Config[:file_cache_path]}/osticket_#{node[:osticket][:version]}.tar.gz"
  creates "#{node[:osticket][:dir]}/ost-config.sample.php"
end

#execute "create-ost-config-php" do
#  cwd "#{node[:osticket][:dir]}/include"
#  command "cp ost-config.sample.php ost-config.php && chmod 666 ost-config.php"
#end

execute "mysql-install-osticket-privileges" do
  command "/usr/bin/mysql -u root -p#{node[:mysql][:server_root_password]} < /etc/mysql/ost-grants.sql"
  action :nothing
end

include_recipe "mysql::server"
require 'rubygems'
Gem.clear_paths
require 'mysql'

template "/etc/mysql/ost-grants.sql" do
  path "/etc/mysql/ost-grants.sql"
  source "grants.sql.erb"
  owner "root"
  group "root"
  mode "0600"
  variables(
    :user     => node[:osticket][:db][:user],
    :password => node[:osticket][:db][:password],
    :database => node[:osticket][:db][:database]
  )
  notifies :run, resources(:execute => "mysql-install-osticket-privileges"), :immediately
end

execute "create #{node[:osticket][:db][:database]} database" do
  command "/usr/bin/mysqladmin -u root -p#{node[:mysql][:server_root_password]} create #{node[:osticket][:db][:database]}"
  not_if do
    m = Mysql.new("localhost", "root", node[:mysql][:server_root_password])
    m.list_dbs.include?(node[:osticket][:db][:database])
  end
end

# save node data after writing the MYSQL root password, so that a failed chef-client run that gets this far doesn't cause an unknown password to get applied to the box without being saved in the node data.
ruby_block "save node data" do
  block do
    node.save
  end
  action :create
end

log "Navigate to 'http://#{server_fqdn}/osticket/index.php' to complete wordpress installation" do
  action :nothing
end

#template "#{node[:wordpress][:dir]}/wp-config.php" do
#  source "wp-config.php.erb"
#  owner "root"
#  group "root"
#  mode "0644"
#  variables(
#    :database        => node[:wordpress][:db][:database],
#    :user            => node[:wordpress][:db][:user],
#    :password        => node[:wordpress][:db][:password],
#    :auth_key        => node[:wordpress][:keys][:auth],
#    :secure_auth_key => node[:wordpress][:keys][:secure_auth],
#    :logged_in_key   => node[:wordpress][:keys][:logged_in],
#    :nonce_key       => node[:wordpress][:keys][:nonce]
#  )
#  notifies :write, resources(:log => "Navigate to 'http://#{server_fqdn}/wp-admin/install.php' to complete wordpress installation")
#end

template "#{node[:osticket][:dir]}/include/ost-config.php" do
  source "ost-config.php.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :database       => node[:osticket][:db][:database],
    :user           => node[:osticket][:db][:user],
    :password       => node[:osticket][:db][:password],
    :dbhost         => node[:osticket][:db][:host],
    :tableprefix    => node[:osticket][:db][:prefix],
    :nonce_key      => node[:osticket][:keys][:nonce],
    :admin_email    => node[:osticket][:users][:admin][:email]
  )
#  notifies :write, resources(:log => "Navigate to 'http://#{server_fqdn}/setup/install.php' to complete the installation.")
end

template "#{Chef::Config[:file_cache_path]}/osticket.sql" do 
  source "osticket.sql.erb"
  owner "root"
  group "root"
  mode "0444"
end

execute "populate #{node[:osticket][:db][:database]} database" do
  command "/usr/bin/mysql -u root -p#{node[:mysql][:server_root_password]} #{node[:osticket][:db][:database]} < #{Chef::Config[:file_cache_path]}/osticket.sql"
end

include_recipe %w{php::php5 php::module_mysql}

web_app "osticket" do
  template "osticket.conf.erb"
  docroot "#{node[:osticket][:dir]}"
  server_name server_fqdn
  server_aliases node.fqdn
end
