include_recipe 'zabbix-jp::default'

%W{
  zabbix-sender
  zabbix-get
  zabbix-server
  zabbix-web-japanese
}.each do |pkg|
  package pkg
end

template '/etc/php.ini' do
  notifies :restart, 'service[httpd]'
end

template '/etc/zabbix/zabbix_server.conf' do
  notifies :restart, 'service[zabbix-server]'
end

template '/etc/zabbix/web/zabbix.conf.php'

%W{
  httpd
  zabbix-server
}.each do |svc|
  service svc do
    supports restart: true, status: true, reload: true
    action   [:enable, :start]
  end
end

include_recipe 'zabbix-jp::init_server'

