#
# Cookbook Name:: rcg-samba-server
# Recipe:: default
#
# Copyright 2011, Matt Harris
#
# All rights reserved - Do Not Redistribute
#

package "ldap-auth-client" do
  action  :install
end

package "ntp" do
  action  :install
end

execute "tls_cert_never" do
  command 'echo "TLS_REQCERT never" >> /etc/ldap/ldap.conf; touch /root/.ldap_tls_cert_never'
  creates "/root/.ldap_tls_cert_never"
end

template "/etc/ldap.conf" do
  source "ldap.conf.erb"
end

template "/etc/auth-client-config/profile.d/open_ldap" do
  source "open_ldap.erb"
end

execute "auth-client-config" do
  command 'auth-client-config -a -p open-ldap; touch /root/.ldap_auth-client-config'
  creates "/root/.ldap_auth-client-config"
end

%w{"krb5-user", "krb5-config", "libkdb5-4", "libgssrpc4"}.each do |pkg|
  package pkg do
    action  :install
  end
end