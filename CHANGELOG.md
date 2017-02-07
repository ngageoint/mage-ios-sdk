# Change Log
All notable changes to this project will be documented in this file.
Adheres to [Semantic Versioning](http://semver.org/).

---
## 1.2.2 (TBD)

##### Features

##### Bug Fixes

## [1.2.1](https://github.com/ngageoint/mage-ios-sdk/releases/tag/1.2.1) (02-07-2017)

##### Features

##### Bug Fixes
* Fixed bug with locations for user sometimes not getting reported.  When checking if user is in an event,  
  need to make sure the check occurs in the same managed object context.

## [1.2.0](https://github.com/ngageoint/mage-ios-sdk/releases/tag/1.1.3) (11-03-2016)

##### Features
* Observation important and favorites

- new data model for favorite and important entities
- incorporated favorites and important in push and pull services

##### Bug Fixes

## [1.1.4](https://github.com/ngageoint/mage-ios-sdk/releases/tag/1.1.4) (12-06-2016)

##### Features
* Prevent MAGE database files from being backed up to iCloud and iTunes

##### Bug Fixes

## [1.1.3](https://github.com/ngageoint/mage-ios-sdk/releases/tag/1.1.3) (09-21-2016)

##### Features

##### Bug Fixes
* Fix bug in location refresh not pulling new user locations after event switch

## [1.1.2](https://github.com/ngageoint/mage-ios-sdk/releases/tag/1.1.2) (08-18-2016)

##### Features
* Parse and format generic geometry property as GeoJson.

##### Bug Fixes

## [1.1.1](https://github.com/ngageoint/mage-ios-sdk/releases/tag/1.1.1) (07-25-2016)

##### Features

##### Bug Fixes
* Change file protection on MAGE database to NSFileProtectionCompleteUnlessOpen.

## [1.1.0](https://github.com/ngageoint/mage-ios-sdk/releases/tag/1.1.0) (06-15-2016)

##### Features
* Added size parameter when pulling attachments, to allow to pull thumbnail if available.

##### Bug Fixes

## [1.0.0](https://github.com/ngageoint/mage-ios-sdk/releases/tag/1.0.0) (06-14-2016)

* Initial release
