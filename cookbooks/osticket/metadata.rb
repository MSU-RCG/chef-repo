maintainer       "Matt Harris"
maintainer_email "matthaeus.harris@gmail.com"
license          "Apache 2.0"
description      "Installs/Configures OSTicket"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "1.0.5"
depends          "php"
depends          "apache2"
depends          "openssl"

recipe "osticket", "Installs and configures OSTicket with a LAMP stack on a single server."

%w{ debian ubuntu }.each do |os|
  supports os
end

attribute "osticket/version",
  :display_name => "OSTicket download version",
  :description => "Version of OSTicket to download from the OSTicket site.",
  :default => "1.6.0"
  
attribute "osticket/checksum",
  :display_name => "OSTicket tarball checksum",
  :description => "Checksum of the tarball for the version specified.",
  :default => "f1311b312a982fa8a888ac971dcdb92339c4fd450e6da8104c41bfab6f78af1a"
  
attribute "osticket/dir",
  :display_name => "OSTicket installation directory",
  :description => "Location to place OSTicket files.",
  :default => "/var/www"
  
attribute "osticket/db/database",
  :display_name => "OSTicket MySQL database",
  :description => "OSTicket will use this MySQL database to store its data.",
  :default => "osticketdb"

attribute "osticket/db/user",
  :display_name => "OSTicket MySQL user",
  :description => "OSTicket will connect to MySQL using this user.",
  :default => "osticketuser"

attribute "osticket/db/password",
  :display_name => "OSTicket MySQL password",
  :description => "Password for the OSTicket MySQL user.",
  :default => "randomly generated"
  
attribute "osticket/db/prefix",
  :display_name => "OSticket MySQL table prefix",
  :description => "Table prefix for allowing more than one osticket install in the same database",
  :default => "ost_"

attribute "osticket/keys/auth",
  :display_name => "OSTicket auth key",
  :description => "OSTicket auth key.",
  :default => "randomly generated"

attribute "osticket/keys/secure_auth",
  :display_name => "OSTicket secure auth key",
  :description => "OSTicket secure auth key.",
  :default => "randomly generated"

attribute "osticket/keys/logged_in",
  :display_name => "OSTicket logged-in key",
  :description => "OSTicket logged-in key.",
  :default => "randomly generated"

attribute "osticket/keys/nonce",
  :display_name => "OSTicket nonce key",
  :description => "OSTicket nonce key.",
  :default => "randomly generated"
  
attribute "osticket/users/admin/email",
  :display_name => "Administrative e-mail",
  :description => "Used only for db connection issues and related alerts.",
  :default => "user@example.com"
