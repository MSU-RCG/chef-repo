include_recipe "apache2"

apache_site "000-default" do
  enable false
end

template "#{node[:apache][:dir]}/sites-available/camtasia_files" do
  source "camtasia_files.erb"
  mode 0644
  if ::File.symlink?("#{node[:apache][:dir]}/sites-enabled/camtasia_files")
    notifies :reload, resources(:service => "apache2")
  end
end

apache_site "camtasia_files"
