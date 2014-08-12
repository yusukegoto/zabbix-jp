include_recipe 'zabbix-jp::default'

%W{
  postgresql-server
  zabbix-server-pgsql
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
