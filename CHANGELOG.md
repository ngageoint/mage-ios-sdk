# Change Log
All notable changes to this project will be documented in this file.
Adheres to [Semantic Versioning](http://semver.org/).

---
## 2.0.2 (02-11-2018)

##### Features

* Additional information about phone network state and battery state are sent with locations

##### Bug Fixes

* Observation geometries are sent properly for location fields
* Archived forms are now filtered out when creating a new observation
* Location Services is not turned on in the case where the app restarts after a force stop

## 2.0.1 (01-24-2018)

##### Features

##### Bug Fixes

* Observation class uses the correct event not the current event
* Protect case where database is unable to be saved to when creating observations

## [2.0](https://github.com/ngageoint/mage-ios-sdk/releases/tag/2.0) (07-28-2017)

##### Features
* Multiple forms per event.
* Delete observation apis
* Pull in access control lists per event from server
* Use iOS background upload for attachments.  This will continue to upload MAGE attachments even if app is backgrounded or suspended.
* Observation geometry support for lines and polygons

##### Bug Fixes

## [1.4.1](https://github.com/ngageoint/mage-ios-sdk/releases/tag/1.4.1) (07-28-2017)

##### Features

##### Bug Fixes
* Fixed DateFormatter bad memory crash

## [1.4.0](https://github.com/ngageoint/mage-ios-sdk/releases/tag/1.4.0) (05-26-2017)

##### Features
* Use new 4.5 MAGE server API to get observation id before sending observation contents.  This will prevent observation duplicates in the case that
  a successful creation response is dropped by the client and the client sends another.
* Added CoreData properties for observation sync and error status.

##### Bug Fixes

## [1.3.0](https://github.com/ngageoint/mage-ios-sdk/releases/tag/1.3.0) (03-28-2017)

##### Features
* AFNetworking upgrade to 3.1.0
* Network Session and Task Managers

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
