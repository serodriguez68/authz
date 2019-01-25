# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
- Maintenance dashboard on the Admin
- Cross request caching feature. It can now be enabled through `config.cross_request_caching = true`
in the initializer. 


## [0.0.1.alpha4] - 2018-01-18
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