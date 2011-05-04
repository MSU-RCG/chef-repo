include_recipe "rvm"

gem_package "ruby-debug19" do
  gem_binary "rvm 1.9.2 gem"
  only_if "test -e /usr/local/bin/rvm"
  options '-- --with-ruby-include="$rvm_path/src/$(rvm tools identifier)/"'
end
