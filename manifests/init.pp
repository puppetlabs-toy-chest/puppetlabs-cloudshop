application cloudshop (
  $dbinstance,
  $dbpassword,
  $dbuser,
  $dbname,
  $dbport        = 1433,
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
    dbport        => $dbport,
    file_source   => $file_source,
    administrator => $administrator,
    export        => Database["orc_sqlapp-${name}"],
  }
  # This 'each' block will set up a given number of
  # Cloudshop applications based on the parameter `app_count`.
  # Each application will be given a name followed by the number
  # starting from 0 up to (app_count - 1)
  $app_count.each |$i| {
    cloudshop::app { "${name}-${i}":
      dbuser      => $dbuser,
      dbinstance  => $dbinstance,
      dbpassword  => $dbpassword,
      dbname      => $dbname,
      dbserver    => $::fqdn,
      iis_site    => $iis_site,
      docroot     => $docroot,
      dbport      => $dbport,
      file_source => $file_source,
      consume     => Database["orc_sqlapp-${name}"],
    }
  }
}
