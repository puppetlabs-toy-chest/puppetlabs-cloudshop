define cloudshop::db ( 
  $dbinstance,
  $dbuser,
  $dbpassword,
  $dbname,
  $dbserver,
  $file_source = 'https://s3-us-west-2.amazonaws.com/tseteam/files/sqlwebapp',
  $administrator = 'vagrant'
){
  class { 'tse_sqlserver':
    admin_user => $administrator,
  }
  class { 'sqlwebapp::db':
    dbinstance    => $dbinstance,
    dbuser        => $dbuser,
    dbpass        => $dbpassword,
    dbname        => $dbname,
    dbserver      => $dbserver,
    require       => Class['tse_sqlserver'],
  }
}
Cloudshop::Db produces Mssql {
  dbinstance => $dbinstance,
  dbuser     => $dbuser,
  dbpassword => $dbpassword,
  dbname     => $dbname,
  dbserver   => $dbserver,
}
