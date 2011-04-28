require "pp"

if platform?("ubuntu")
  platform = "Ubuntu"
end

if platform?("debian")
  platform = "Debian"
end

remote_file "#{Chef::Config[:file_cache_path]}/glusterfs_#{node[:gluster][:version]}-1_amd64.deb" do
  checksum node[:osticket][:checksum]
  source "http://download.gluster.com/pub/gluster/glusterfs/#{node[:gluster][:majorversion]}/#{node[:gluster][:version]}/#{platform}/glusterfs_#{node[:gluster][:version]}-1_amd64.deb"
  mode "0644"
end

dpkg_package "glusterfs" do
  source "#{Chef::Config[:file_cache_path]}/glusterfs#{node[:gluster][:version]}-1_amd64.deb"
  version node[:gluster][:version]
end