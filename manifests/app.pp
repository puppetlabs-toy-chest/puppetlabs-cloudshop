define cloudshop::app (
  $dbserver,
  $dbinstance,
  $dbpassword,
  $dbuser,
  $dbport,
  $dbname,
  $iis_site      = 'Default Web Site',
  $docroot       = 'C:/inetpub/wwwroot',
  $file_source   = 'https://s3-us-west-2.amazonaws.com/tseteam/files/sqlwebapp',
  $port = 80,
){
  # sqlwebapp iis
  windowsfeature { 'IIS_APPSERVER':
    feature_name => [
      'Web-Server',
      'Net-Framework-45-ASPNET',
      'Application-Server',
      'AS-NET-Framework',
      'AS-Web-Support',
      'Web-Mgmt-Tools',
      'Web-Mgmt-Console',
      'Web-Scripting-Tools',
      'Web-WebServer',
      'Web-App-Dev',
      'Web-Asp-Net45',
      'Web-ISAPI-Ext',
      'Web-ISAPI-Filter',
      'Web-Net-Ext45',
      'Web-Common-Http',
      'Web-Default-Doc',
      'Web-Dir-Browsing',
      'Web-Http-Errors',
      'Web-Http-Redirect',
      'Web-Static-Content',
      'Web-Health',
      'Web-Http-Logging',
      'Web-Log-Libraries',
      'Web-Request-Monitor',
      'Web-Stat-Compression',
      'Web-Dyn-Compression',
      'Web-Security',
      'Web-Basic-Auth',
      'Web-Cert-Auth',
      'Web-Client-Auth',
      'Web-Digest-Auth',
      'Web-Filtering',
      'Web-IP-Security',
      'Web-Url-Auth',
      'Web-Windows-Auth',
    ]
  }

  # sqlwebapp init
  file { 'C:/inetpub':
    ensure => directory,
  }

  file { $docroot:
    ensure  => directory,
  }

  file { "${docroot}/CloudShop":
    ensure  => directory,
  }
  staging::file { 'CloudShop.zip':
    source => "${file_source}/CloudShop.zip",
  }
  unzip { 'Unzip webapp CloudShop':
    source      => "C:/ProgramData/staging/${module_name}/CloudShop.zip",
    creates     => "${docroot}/CloudShop/Web.config",
    destination => "${docroot}/CloudShop",
    require     => Staging::File['CloudShop.zip'],
    notify      => Exec['ConvertAPP'],
  }
  file { "${docroot}/CloudShop/Web.config":
    ensure  => present,
    content => template("${module_name}/Web.config.erb"),
    require => Unzip['Unzip webapp CloudShop'],
  }
  exec { 'ConvertAPP':
    command     => "ConvertTo-WebApplication \'IIS:/Sites/${iis_site}/CloudShop\'",
    provider    => powershell,
    refreshonly => true,
  }
}
Cloudshop::App produces Http {
  host => $fqdn,
  ip   => $ipaddress,
  port => $port,
}
Cloudshop::App consumes Database {
  instance => $dbinstance,
  user     => $dbuser,
  password => $dbpassword,
  name     => $dbname,
  host     => $dbserver,
  port     => $dbport,
}
