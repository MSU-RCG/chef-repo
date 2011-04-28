require "pp"

mount "/mnt/gluster" do
  action  [:enable, :mount]
  device  "porthos.rcg.montana.edu:/glustervol1"
  fstype  "glusterfs"
  options "rw,allow_other,default_permissions,max_read=131072"
  dump    0
  pass    0
end