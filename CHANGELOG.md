# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added

## [0.0.4] - 2019-11-03
### Added
- Bump the dummy app's devise version from 4.5.0 to 4.7.1. Version 4.5.0 had a security vulnerability that did not 
impact the security of Authz.

## [0.0.3] - 2018-02-11
### Added
- Enforce uniqueness in data model through database level indexes
- Add YARD compatible documentation

## [0.0.2] - 2018-02-02
### Added
- Help text in the admin

## [0.0.1] - 2018-01-28
### Added
- Maintenance dashboard on the Admin

## [0.0.1.alpha5] - 2018-01-27
### Added
- Cross request caching feature. It can now be enabled through `config.cross_request_caching = true`
in the initializer.
- `current_user.roles_cache_key` now gives you an auto-expiring key that can be used as part of
your fragment caching keys.


## [0.0.1.alpha4] - 2018-01-22
### Added
- Add `rails g authz:install` as part of the installation process.
- Add `rake authz:seed_admin` task to create an initial business process
capable of accessing the app.
- The Admin is now authorized using the Authz infrastructure
- The current_user and force authentication methods are now 
configured through an initializer and NOT by overriding them

### Removed
- `rails authz:install:migrations` is no longer required as part of the installation.
It has been replaced by the `rails g authz:install` generator.
  

## [0.0.1.alpha3] - 2018-01-18
### Fixed
- Broken link to changelog

## [0.0.1.alpha2] - 2018-01-18
### Added
- First core functionality release