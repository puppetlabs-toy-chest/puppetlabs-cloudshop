# CloudShop

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with CloudShop](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with CloudShop](#beginning-with-CloudShop)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

CloudShop is a Microsoft Windows e-commerce application, and this module sets up a basic all-in-one or split CloudShop installation. Using this module you can install and configure a Microsoft SQL Server instance with an AdventureWorks2012 database that is served to an ASP.NET application hosted on IIS. 

This module is only compatible with the application language constructs available in Puppet 4. More specifically, this module models the dependencies between the database and web components that make up the CloudShop application. By modeling these dependencies, Puppet is able to determine the node run order in which to configure the application.

### Beginning with CloudShop

To use this module, you need at least one Windows server.

## Usage

The following example shows two CloudShop application instances---a split install and an all-in-one install.

```
site {
  cloudshop { 'allinone':
    dbinstance              => 'MYINSTANCE',
    dbuser                  => 'CloudShop',
    dbpassword              => 'Azure$123',
    dbname                  => 'AdventureWorks2012',
    app_count               => 1,
    administrator           => 'Administrator',
    nodes                   => {
      Node['forthewindows'] => [Cloudshop::App['allinone-0'], Cloudshop::Db['allinone']],
    },
  }

  cloudshop { 'split':
    dbinstance              => 'MYINSTANCE',
    dbuser                  => 'CloudShop',
    dbpassword              => 'Azure$123',
    dbname                  => 'AdventureWorks2012',
    app_count               => 1,
    administrator           => 'Administrator',
    nodes                   => {
      Node['cloudshopapp']  => Cloudshop::App['split-0'],
      Node['cloudshopdb']   => Cloudshop::Db['split'],
    },
  }
}
```

## Reference

### Application CloudShop

* `dbinstance`: The name of the database instance for the Microsoft SQL Server instance.
* `dbpassword`: The password to use for the Microsoft SQL Server instance.
* `dbuser`: The user to log into the Microsoft SQL Server instance.
* `dbname`: The name of the Microsoft SQL Server instance.
* `dbport`: The port the Microsoft SQL Server listens on.
* `iss_site`: The IIS directory that contains the CloudShop module.
* `docroot`: The directory on disk from which your website is hosted.
* `file_source`: The location for obtaining the Microsoft SQL Server ISO or the location of the CloudShop application archive.
* `administrator`: The user used to install the Microsoft SQL Server.
* `app_count`: The number of CloudShop application instances to set up.

## Limitations

### Known Issues

On the first run, the application will fail. This is a known issue

```
Error running puppet on server2012r2a.pdx.puppetlabs.demo: C:/ProgramData/PuppetLabs/puppet/cache/state/last_run_report.yaml could not be loaded: undefined class/module Puppet::Type::Acl::
```

#### Known Solution

Run the job a second time and the run should succeed

## Development

## Release Notes/Contributors/Etc.

Thanks to James E. Jones for all of the work to get this module going and set up.
