define cloudshop::db (
  $dbuser,
  $dbpassword,
  $dbname,
  $dbserver,
  $file_source = 'https://s3-us-west-2.amazonaws.com/tseteam/files/sqlwebapp',
  $administrator = 'vagrant',
  $mount_iso = true,
  $iso = 'SQLServer2014-x64-ENU.iso',
  $sqlserver_version = '2014',
  $iso_source = 'https://s3-us-west-2.amazonaws.com/tseteam/files/tse_sqlserver',
  $iso_drive = 'F',
  $mdf_file      = 'AdventureWorks2012_Data.mdf',
  $ldf_file      = 'AdventureWorks2012_log.ldf',
  $zip_file      = 'AdventureWorks2012_Data.zip',
  $dbinstance    = 'MYINSTANCE',
  $owner         = 'CloudShop',
  $dbpass        = 'Azure$123',
  $source      = 'F:/',
  $sa_pass     = 'Password$123$',
  $staging_path = 'C:\ProgramData\staging',
  $staging_owner = 'BUILTIN\Administrators',
  $staging_group = 'NT AUTHORITY\SYSTEM',
  $dbport = 1433,
){
  # tse_sqlserver init
  if $mount_iso {
    staging::file { $iso:
      source => "${iso_source}/${iso}",
    }

    $iso_path = "${staging_path}\\${module_name}\\${iso}"

    acl { $iso_path :
      permissions => [
        {
          identity => 'Everyone',
          rights   => [ 'full' ]
        },
        {
          identity => $staging_owner,
          rights   => [ 'full' ]
        },
      ],
      require     => Staging::File[$iso],
      before      => Mount_iso[$iso_path],
    }

    mount_iso { $iso_path :
      drive_letter => $iso_drive,
      before       => Sqlserver_features['Management_Studio'],
    }
  }
  # tse_sqlserver sql
  case $sqlserver_version {
    '2012':  {
      $version_var  = 'MSSQL11'
      $data_path  = "C:\\Program Files\\Microsoft SQL Server\\MSSQL11.${$dbinstance}\\MSSQL\\DATA"
      $sqlps_path = 'C:\Program Files (x86)\Microsoft SQL Server\110\Tools\PowerShell\Modules\SQLPS'
    }
    '2014':  {
      $version_var  = 'MSSQL12'
      $data_path  = "C:\\Program Files\\Microsoft SQL Server\\MSSQL12.${dbinstance}\\MSSQL\\DATA"
      $sqlps_path = 'C:\Program Files (x86)\Microsoft SQL Server\120\Tools\PowerShell\Modules\SQLPS'
    }
    default: {
      fail("Unknown sqlserver_version '${sqlserver_version}'")
    }
  }

  reboot { 'before install':
      when => pending,
  }

  service { 'wuauserv':
    ensure => running,
    enable => true,
    before => Windowsfeature['Net-Framework-Core'],
  }

  windowsfeature { 'Net-Framework-Core':
    before => Sqlserver_instance[$dbinstance],
  }

  sqlserver_instance{ $dbinstance:
    ensure                => present,
    features              => ['SQL'],
    source                => $source,
    security_mode         => 'SQL',
    sa_pwd                => $sa_pass,
    sql_sysadmin_accounts => [$administrator],
  }

  sqlserver_features { 'Management_Studio':
    source   => $source,
    features => ['SSMS'],
  }

  sqlserver::config{ $dbinstance:
    admin_user => 'sa',
    admin_pass => $sa_pass,
  }

  windows_firewall::exception { 'Sql browser access':
    ensure       => present,
    direction    => 'in',
    action       => 'Allow',
    enabled      => 'yes',
    program      => 'C:\Program Files (x86)\Microsoft SQL Server\90\Shared\sqlbrowser.exe',
    display_name => 'MSSQL Browser',
    description  => "MS SQL Server Browser Inbound Access, enabled by Puppet in ${module_name}",
  }

  windows_firewall::exception { 'Sqlserver access':
    ensure       => present,
    direction    => 'in',
    action       => 'Allow',
    enabled      => 'yes',
    program      => "C:\\Program Files\\Microsoft SQL Server\\${version_var}.${dbinstance}\\MSSQL\\Binn\\sqlservr.exe",
    display_name => 'MSSQL Access',
    description  => "MS SQL Server Inbound Access, enabled by Puppet in ${module_name}",
  }

  staging::file { $zip_file:
    source => "${file_source}\\${zip_file}",
  }
  unzip { "SQL Data ${zip_file}":
    source    => "${staging_path}\\${module_name}\\${zip_file}",
    creates   => "${data_path}\\${mdf_file}",
    subscribe => Staging::File[$zip_file],
  }
  exec { "Attach ${title}":
    command  => "import-module \'${sqlps_path}\'; invoke-sqlcmd \"USE [master] CREATE DATABASE [${title}] ON (FILENAME = \'${data_path}\\${mdf_file}\'),(FILENAME = \'${data_path}\\${ldf_file}\') for ATTACH\" -QueryTimeout 3600  -username \'sa\' -password \'${::tse_sqlserver::sql::sa_pass}\' -ServerInstance \'${::hostname}\\${dbinstance}\'",
    provider => powershell,
    path     => $sqlps_path,
    onlyif   => "import-module \'${sqlps_path}\'; invoke-sqlcmd -Query \"select [name] from sys.databases where [name] = \'${title}\';\" -ServerInstance \"${::hostname}\\${dbinstance}\"| write-error",
  }
  exec { "Change owner of ${title}":
    command   => "import-module \'${sqlps_path}\'; invoke-sqlcmd \"USE [${title}] ALTER AUTHORIZATION ON DATABASE::${title} TO ${owner};\" -QueryTimeout 3600 -username \'sa\' -password \'${::tse_sqlserver::sql::sa_pass}\' -ServerInstance \'${::hostname}\\${dbinstance}\'",
    provider  => powershell,
    onlyif    => "import-module \'${sqlps_path}\'; invoke-sqlcmd -Query \"select suser_sname(owner_sid) from sys.databases where [name] = \'${title}\';\" -ServerInstance \"${::hostname}\\${dbinstance}\" | where-object \"Column1\" -eq \"${owner}\" | write-error",
    subscribe => Exec["Attach ${title}"],
  }
  sqlserver::login{ $owner:
    instance => $dbinstance,
    password => $dbpass,
    notify   => Exec["Attach ${title}"],
    require  => Unzip["SQL Data ${zip_file}"],
  }
}
Cloudshop::Db produces Database {
  instance => $dbinstance,
  user     => $dbuser,
  password => $dbpassword,
  name     => $dbname,
  host     => $dbserver,
  port     => $dbport,
}
