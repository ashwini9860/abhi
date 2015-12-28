#
# Cookbook Name:: apache
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
execute "update" do
	command "apt-get update -y"
	action :run
end

package "apache2" do
	action :install
end

execute "mv /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.disable" do
 only_if do
  File.exist?("/etc/apache2/sites-available/000-default.conf")
 end
 notifies :restart, "service[apache2]"
end

node["abhi"]["sites"].each do |site_name, site_data|
 document_root = "/srv/abhi/#{site_name}"

template "/etc/apache2/sites-available/#{site_name}.conf" do
 source "custom.erb"
 mode "0644"
 variables(
  :document_root => document_root,
  :port => site_data["port"]
 )
 notifies :restart, "service[apache2]"
end
directory document_root do
 mode "0755"
 recursive true
end
template "#{document_root}/index.html" do
 source "index.html.rrb"
 mode "0644"
 variables(
  :site_name => site_name,
  :port => site_data["port"]
 )
 end
end
service "apache2" do
 action [ :enable, :start ]
end

