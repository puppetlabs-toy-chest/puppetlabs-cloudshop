# Cloudshop

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with Cloudshop](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with Cloudshop](#beginning-with-Cloudshop)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

This module sets up a basic Cloudshop all-in-one or split installation. Cloudshop is a basic example Microsoft Windows e-commerce application. This module will install and setup a MS SQL Server instance with the AdventureWorks2012 DB and serve that to a ASP.NET application hosted on IIS. This is intended to work with the new application language constructs in puppet 4.

Specifically this module helps model the dependencies between the database and web components to make up the application Cloudshop. By modeling these dependencies, puppet is able to determine which node to run and set up first.

### Beginning with Cloudshop

A user will need at least one windows server if they want to use this module.

## Usage

Here is an example of two application instances. A split Cloudshop and an all in one Cloudshop.

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

### Application Cloudshop

* `dbinstance`
  + The name of the database instance for MS SQL Server
* `dbpassword`
  + The password to use for your MS SQL database instance
* `dbuser`
  + The user to log into your MS SQL database instance
* `dbname`
  + The name of your MS SQL database
* `dbport`
  + The port that MS SQL Server is listening on
* `iss_site`
  + The directory that your Cloudshop module should go under in IIS
* `docroot`
  + The directory on disk where your website should be hosted from
* `file_source`
  + The location for obtaining either MS SQL Server iso or the Cloudshop application archive
* `administrator`
  + The user that should be used to install MS Sql
* `app_count`
  + How many Cloudshop application instances you wish to set up

## Limitations

### Known Issues

https://tickets.puppetlabs.com/browse/ORCH-1285

On the first run, the application will fail. This is a known issue

```
Error running puppet on server2012r2a.pdx.puppetlabs.demo: C:/ProgramData/PuppetLabs/puppet/cache/state/last_run_report.yaml could not be loaded: undefined class/module Puppet::Type::Acl::
```

#### Known Solution

Run the job a second time and the run should succeed

## Development

## Release Notes/Contributors/Etc.

Thanks to James E. Jones for all of the work to get this module going and set up.
