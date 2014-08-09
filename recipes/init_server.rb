phpzabbixapi_bz2 = 'PhpZabbixApi_Library.tar.bz2'
tmp_dir = Chef::Config[:file_cache_path]

unzip_cmd = <<UNZIP
cd #{ tmp_dir };
curl -L "http://zabbixapi.confirm.ch/download.php?file=library" > #{ phpzabbixapi_bz2 };
tar xfj #{ phpzabbixapi_bz2 };
UNZIP

execute unzip_cmd do
  not_if "test -d #{ tmp_dir }/PhpZabbixApi_Library"
  action :run
end

setup_php = "#{ tmp_dir }/setup.php"

template setup_php do
  notifies :run, 'execute[setup_zabbix]'
end

execute 'setup_zabbix' do
  command "php #{ setup_php }"
  action :nothing
end
