#node[:mysql][:server_root_password] = 's3cr3t'

#include_recipe "mysql::server"

yum_package 'java-1.6.0-openjdk'
yum_package 'ghostscript-fonts'

bash "Fetch Bamboo" do
  not_if "test -f /tmp/atlassian-bamboo-#{node[:bamboo][:version]}-standalone.tar.gz"
  user "root"
  cwd "/tmp"
  code <<-EOH
    wget http://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-#{node[:bamboo][:version]}-standalone.tar.gz -O /tmp/atlassian-bamboo-#{node[:bamboo][:version]}-standalone.tar.gz
  EOH
end

bash "Install Bamboo" do
  not_if "test -d #{node[:bamboo][:app]}"
  user "root"
  cwd "/tmp"
  code <<-EOH
    tar -zxf /tmp/atlassian-bamboo-#{node[:bamboo][:version]}-standalone.tar.gz
    mv /tmp/Bamboo #{node[:bamboo][:app]}
  EOH
end

directory node.bamboo.home do
  recursive true
  action :create
end

template "#{node[:bamboo][:app]}/webapp/WEB-INF/classes/bamboo-init.properties" do
  source "bamboo-init.properties.erb"
  group "root"
  owner "root"
  mode 0644
end

# template "#{node[:bamboo][:home]}/bamboo.cfg.xml" do
#   source "bamboo.cfg.xml.erb"
#   group "root"
#   owner "root"
#   mode 0644
# end


bash "Restart Bamboo" do
  user "root"
  cwd "#{node[:bamboo][:app]}"
  code <<-EOH
    ./bamboo.sh restart
  EOH
end


#(cd atlassian-bamboo-node[:bamboo][:version]-standalone/ && ./configure && make && make install)