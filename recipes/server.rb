include_recipe 'zabbix-jp::default'

%W{
  postgresql-server
  zabbix-sender
  zabbix-get
  zabbix-server
  zabbix-server-pgsql
  zabbix-web-japanese
  zabbix-web-pgsql
}.each do |pkg|
  package pkg
end

pg_base = '/var/lib/pgsql/data'
initdb_cmd = <<-PG
  cd #{ pg_base };
  initdb --locale=ja_JP.UTF-8 .
PG

db_user = 'postgres'

execute initdb_cmd do
  not_if { File.exists? "#{ pg_base }/PG_VERSION" }
  user  db_user
  group db_user
  action :run
end

%W{
  httpd
  postgresql
  zabbix-server
}.each do |svc|
  service svc do
    supports restart: true, status: true, reload: true
    action   [:enable, :start]
  end
end

service 'postgresql' do
  supports restart: true, status: true, reload: true
  action   [:enable, :start]
  notifies :run, 'execute[zabbix_db_init]'
end

zabbix_db_init_cmd = <<-ZABBIXDB
  cd /usr/share/doc/zabbix-server-pgsql-2.2.5/create
  cat schema.sql images.sql data.sql | psql -U #{ db_user }
ZABBIXDB

execute 'zabbix_db_init' do
  not_if "pgsql -U #{ db_user } -c '\d mainenances'"
  command zabbix_db_init_cmd
  user  db_user
  group db_user
  action :nothing
end

template '/etc/php.ini' do
  notifies :restart, 'service[httpd]'
end

template '/etc/zabbix/zabbix_server.conf' do
  notifies :restart, 'service[zabbix-server]'
end

template '/etc/zabbix/web/zabbix.conf.php'

include_recipe 'zabbix-jp::init_server'

