maintainer       "Matthew Harris"
maintainer_email "matthaeus.harris@gmail.com"
license          "All rights reserved"
description      "Installs/Configures gluster"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1.1"

recipe "glusterd", "Installs the glusterd package"

%w{ debian ubuntu }.each do |os|
  supports os
end

attribute "glusterfs/version",
  :display_name => "Full gluster version",
  :description => "Full version number for gluster",
  :default => "3.1.3"
  
attribute "glusterfs/majorversion",
  :display_name => "Major gluster version",
  :description => "Major version number for gluster (e.g. 3.1)",
  :default => "3.1"
  
attribute "glusterfs/ubuntu/checksum",
  :display_name => "Ubuntu Checksum",
  :description => "Ubuntu Checksum",
  :default => "836542f366d5c3d531fa39a295a41c6b5a31f19a20b8eac5e4a1e96c09de8033"
  
attribute "glusterfs/debian/checksum",
  :display_name => "Debian Checksum",
  :description => "Debian Checksum",
  :default => "fa076d34b09ba4e50def29ff11d51ce646d270596aabe5455135a9bc52f7f94a"
  
attribute "glusterfs/cloud_id",
  :display_name => "Cloud ID",
  :description => "Defines to which file cloud the server will belong",
  :default => "default"