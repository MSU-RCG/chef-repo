#
# Cookbook Name:: glusterd
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
require "pp"

if platform?("ubuntu")
  platform = "Ubuntu"
  filechecksum = node[:glusterfs][:ubuntu][:checksum]
end

if platform?("debian")
  platform = "Debian"
  filechecksum = node[:glusterfs][:debian][:checksum]
end
#pp node
#pp node[:gluster]
#pp platform
if node[:glusterfs][:package_url] == nil
  url = "http://download.gluster.com/pub/gluster/glusterfs/#{node[:glusterfs][:majorversion]}/#{node[:glusterfs][:version]}/#{platform}/glusterfs_#{node[:glusterfs][:version]}-1_amd64.deb"
else
  url = node[:glusterfs][:package_url]
end
pp url

remote_file "#{Chef::Config[:file_cache_path]}/glusterfs_#{node[:glusterfs][:version]}-1_amd64.deb" do
  checksum checksum
  source   url
  mode "0644"
end

package "nfs-common" do
end

dpkg_package "glusterfs" do
  source "#{Chef::Config[:file_cache_path]}/glusterfs_#{node[:glusterfs][:version]}-1_amd64.deb"
  version node[:glusterfs][:version]
end

execute "fuse_module" do
  command 'echo "fuse" >> /etc/modules; modprobe fuse; touch /root/.fuse_module_loaded'
  creates "/root/.fuse_module_loaded"
end

search(:node, "cloud_id:#{node[:glusterfs][:cloud_id]}") do |host|
  pp host[:fqdn]
end