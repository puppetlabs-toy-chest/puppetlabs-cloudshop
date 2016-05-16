application cloudshop (
  $dbinstance,
  $dbpassword,
  $dbuser,
  $dbname,
  $iis_site      = 'Default Web Site',
  $docroot       = 'C:/inetpub/wwwroot',
  $file_source   = 'https://s3-us-west-2.amazonaws.com/tseteam/files/sqlwebapp',
  $administrator = 'vagrant',
  $app_count = 2,
) {
  cloudshop::db { $name:
    dbuser        => $dbuser,
    dbinstance    => $dbinstance,
    dbpassword    => $dbpassword,
    dbname        => $dbname,
    dbserver      => $::fqdn,
    file_source   => $file_source,
    administrator => $administrator,
    export        => Mssql["orc_sqlapp-${name}"],
  }
  $app_count.each |$i| {
    cloudshop::app { "${name}-${i}":
      iis_site    => $iis_site,
      docroot     => $docroot,
      file_source => $file_source,
      consume     => Mssql["orc_sqlapp-${name}"],
    }
  }
}
