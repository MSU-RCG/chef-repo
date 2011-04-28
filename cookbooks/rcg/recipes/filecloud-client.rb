require "pp"

execute "fuse_module" do
  command 'echo "fuse" >> /etc/modules; modprobe fuse; touch /root/.fuse_module_loaded'
  creates "/root/.fuse_module_loaded"
end

remote_file "/root/glusterfs_3.1.2-1_amd64.deb" do
  source "http://download.gluster.com/pub/gluster/glusterfs/3.1/3.1.2/Ubuntu/glusterfs_3.1.2-1_amd64.deb"
  mode "0644"
end

apt_package "libibverbs1" do
  action :install
end

apt_package "nfs-common" do
  action  :install
end

dpkg_package "glusterfs" do
  source  "/root/glusterfs_3.1.2-1_amd64.deb"
  version "3.1.2"
#  action  :install
end


