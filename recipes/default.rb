#
# Cookbook Name:: zabbix-jp
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'localedef'

yum_repository 'epel' do
  description 'Extra Packages for Enterprise Linux'
  mirrorlist 'http://mirrors.fedoraproject.org/mirrorlist?repo=epel-6&arch=$basearch'
  gpgkey 'http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6'
end

yum_repository 'zabbix-release-2.2-1.el6.noarch.rpm' do
  baseurl 'http://repo.zabbix.com/zabbix/2.2/rhel/6/x86_64/'
  gpgkey 'http://repo.zabbix.com/RPM-GPG-KEY-ZABBIX'
end

package 'zabbix-agent'

service 'zabbix-agent' do
  supports restart: true, status: true, reload: true
  action   [:enable, :start]
end

template '/etc/zabbix/zabbix_agentd.conf' do
  notifies :restart, 'service[zabbix-agent]'
end
