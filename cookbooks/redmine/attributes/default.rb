# Cookbook Name:: redmine
# Attributes:: redmine
#
# Copyright 2009, Opscode, Inc
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

require 'openssl'

pw = String.new

while pw.length < 20
  pw << OpenSSL::Random.random_bytes(1).gsub(/\W/, '')
end

#database_server = search(:node, "database_master:true").map {|n| n['fqdn']}.first

set[:redmine][:dir] = "/var/rails/redmine-#{redmine[:version]}"
set[:redmine][:basedir] = "/var/rails"

default[:redmine][:dl_id]   = "56909"
default[:redmine][:version] = "0.8.4"

default[:redmine][:db][:type]     = "sqlite"
default[:redmine][:db][:user]     = "redmine"
default[:redmine][:db][:password] = pw
default[:redmine][:db][:hostname] = "localhost"
default[:redmine][:db][:database] = "redmine"
default[:redmine][:db][:development][:database] = "redmine_development"
default[:redmine][:db][:test][:database] = "redmine_test"
