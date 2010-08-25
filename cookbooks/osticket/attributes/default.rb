#
# Author:: Barry Steinglass (<barry@opscode.com>)
# Cookbook Name:: wordpress
# Attributes:: wordpress
#
# Copyright 2009-2010, Opscode, Inc.
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

# General settings
default[:osticket][:version] = "1.6.0"
default[:osticket][:checksum] = "f1311b312a982fa8a888ac971dcdb92339c4fd450e6da8104c41bfab6f78af1a"
default[:osticket][:dir] = "/var/www/osticket"
default[:osticket][:db][:database] = "osticketdb"
default[:osticket][:db][:user] = "osticketuser"

::Chef::Node.send(:include, Opscode::OpenSSL::Password)

default[:osticket][:db][:password] = secure_password
default[:osticket][:keys][:auth] = secure_password
default[:osticket][:keys][:secure_auth] = secure_password
default[:osticket][:keys][:logged_in] = secure_password
default[:osticket][:keys][:nonce] = secure_password
