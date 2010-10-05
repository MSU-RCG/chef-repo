#
# Cookbook Name:: rcg
# Recipe:: default
#
# Copyright 2010, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

require "pp"

package "ntp"
package "libshadow-ruby1.8"

# Load the admin group onto all machines regardless of local configuration
admins = data_bag_item("groups","admin")
adminlist = []
#pp admins
admins['users'].each do |username|
  useritem = data_bag_item("users",username)
#  pp useritem
  adminlist.push(useritem['id'])
  user(useritem['id']) do
    uid           useritem['uid']
    gid           useritem['gid']
    shell         useritem['shell']
    comment       useritem['comment']
    home          useritem['home']
    password      useritem['password']
    supports      :manage_home => true
  end
  
  if useritem['ssh']
    directory "#{useritem['home']}/.ssh" do
      action      :create
      owner       useritem['id']
      group       useritem['gid']
      mode        0755
    end
    
    template "#{useritem['home']}/.ssh/authorized_keys2" do 
      source "authorized_keys2.erb"
      variables(:ssh_key => useritem['ssh']['dsa_id'])
      owner useritem['id']
      group useritem['gid']
      mode 0644
    end
  end
end

group "admin" do
  members   adminlist
end

template "/etc/sudoers" do
  source "sudoers.erb"
  mode 0440
  owner "root"
  group "root"
end

@local_users = []
begin
  node[:users].each do |role_user|
    @local_users << role_user
  end
  node[:localusers].each do |local_user|
    @local_users << local_user
  end
rescue => err
  puts err
end

#pp @local_users

@local_users.each do |local_user|
  u = data_bag_item("users",local_user)
  user u['id'] do
    uid           u['uid']
    gid           u['gid']
    shell         u['shell']
    comment       u['comment']
    home          u['home']
    password      u['password']
    supports      :manage_home => true
  end

  if u['ssh']
    directory "#{u['home']}/.ssh" do
      action      :create
      owner       useritem['id']
      group       useritem['gid']
      mode        0755
    end

    template "#{u['home']}/.ssh/authorized_keys2" do 
      source "authorized_keys2.erb"
      variables(:ssh_key => u['ssh']['dsa_id'])
      owner useritem['id']
      group useritem['gid']
      mode 0644
    end
  end
end

@local_groups = []
begin
  node[:groups].each do |role_group|
    @local_groups << role_group
  end
  node[:localgroups].each do |local_group|
    @local_groups << local_group
  end
rescue => err
  puts err
end

@local_groups.each do |local_group|
  g = data_bag_item("groups",local_group)
  group g['id'] do 
    gid       g['gid']
    members   g['users']
  end
end
