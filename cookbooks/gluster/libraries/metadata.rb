maintainer       "Matt Harris"
maintainer_email "matthaeus.harris@gmail.com"
license          "Apache 2.0"
description      "Installs gluster"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1.0"

recipe "gluster", "Installs gluster"

%w{ debian ubuntu }.each do |os|
  supports os
end