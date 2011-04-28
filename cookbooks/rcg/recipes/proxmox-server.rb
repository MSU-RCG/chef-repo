template "/etc/pve/storage.cfg" do
  source  "storage.cfg.erb"
  mode    0644
  owner   "root"
  group   "root"
end