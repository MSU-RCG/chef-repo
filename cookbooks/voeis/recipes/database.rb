# Setup Postgres
include_recipe "postgresql::server"
package "libpq-dev"

template "#{node[:postgresql][:dir]}/pg_hba.conf" do
  source "debian.pg_hba.conf.erb"
  owner "postgres"
  group "postgres"
  mode 0600
  notifies :reload, resources(:service => "postgresql")
end

db_user = node[:voeis][:database][:user]
bash "Creating '#{db_user}' user for Postgres" do
  user "postgres"
  code "createuser --no-superuser --no-createrole --createdb #{db_user} || echo 'Vagrant #{db_user} exists'"
end

# Install Sqlite3
package "sqlite3"
package "libsqlite3-dev"
