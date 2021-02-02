# Change Log
All notable changes to this project will be documented in this file.
Adheres to [Semantic Versioning](http://semver.org/).

---
## [3.1.1] (TBD)

##### Features

##### Bug Fixes

## [3.1.0](https://github.com/ngageoint/mage-ios-sdk/releases/tag/3.1.0) (02-02-2021)

##### Features
* Json Web Token authorization support.
* DataConnectionUtilities class can be used to determine if different MAGE data should be pushed or pulled
* Added Network Sync Options for preferences views
* Added methods to the Observation class to pull feed field display values
* Upgrade to AFNetworking 4.x, removes support for deprecated UIWebView 

##### Bug Fixes

## [3.0.8](https://github.com/ngageoint/mage-ios-sdk/releases/tag/3.0.7) (04-30-2020)

##### Features

##### Bug Fixes
* Update ignored url list when checking for token expiration

## [3.0.7](https://github.com/ngageoint/mage-ios-sdk/releases/tag/3.0.7) (04-27-2020)

##### Features
* Updated to GeoPackage-iOS 4.0.1

##### Bug Fixes

## [3.0.6](https://github.com/ngageoint/mage-ios-sdk/releases/tag/3.0.6) (03-24-2020)

##### Features

##### Bug Fixes
* Set loaded property on static layers after download.
* Account for no selected online layers.

## [3.0.5](https://github.com/ngageoint/mage-ios-sdk/releases/tag/3.0.5) (01-06-2020)

##### Features
* Support XYZ/WMS/TMS layers

##### Bug Fixes

## [3.0.4](https://github.com/ngageoint/mage-ios-sdk/releases/tag/3.0.4) (09-27-2019)

##### Features
* Added SAML authentication support.
* Migrate deprecated Objective-Zip library to SSZipArchive library.
* Bump iOS version to 12

##### Bug Fixes

## [3.0.3](https://github.com/ngageoint/mage-ios-sdk/releases/tag/3.0.3) (06-28-2019)

##### Features
* LDAP authentication module.

##### Bug Fixes

## [3.0.2](https://github.com/ngageoint/mage-ios-sdk/releases/tag/3.0.2) (05-02-2019)

##### Features
* Update default image upload size to original

##### Bug Fixes

## [3.0.1](https://github.com/ngageoint/mage-ios-sdk/releases/tag/3.0.1) (03-29-2019)

##### Features

##### Bug Fixes
* Fix bug where observation notifcation could cause crash.

## [3.0.0](https://github.com/ngageoint/mage-ios-sdk/releases/tag/3.0.0) (02-19-2019)

##### Features
* Cache observation image map annotations 

##### Bug Fixes
* Added unique constraint to observation remoteId
* Save observation chunks to root svaing context on correct thread

## [2.0.10](https://github.com/ngageoint/mage-ios-sdk/releases/tag/2.0.10) (02-15-2019)

##### Features
* Save observation to core data in chunks.
* Added coredata migrations for all versions to version 15

##### Bug Fixes

## [2.0.9](https://github.com/ngageoint/mage-ios-sdk/releases/tag/2.0.9) (01-22-2019)

##### Features
* Upgrade GeoPackage dependency to 3.2.1

##### Bug Fixes

## [2.0.8](https://github.com/ngageoint/mage-ios-sdk/releases/tag/2.0.8) (10-4-2018)

##### Bug Fixes

* Handle the case where the observation has no forms even if the event does

## [2.0.7](https://github.com/ngageoint/mage-ios-sdk/releases/tag/2.0.7) (09-21-2018)

##### Bug Fixes

* Handle the case where multiple GeoPackages were uploaded with the same name
* Properly compare server and app versions to compare compatibility

## [2.0.6](https://github.com/ngageoint/mage-ios-sdk/releases/tag/2.0.6) (08-09-2018)

##### Features

* Adds canary object to ensure the database is open and writeable
* Upgrade AFNetworking to 3.2.1

##### Bug Fixes

* Corrects local notification text
* Notifications will now bulk notify if more than 1 observation was pulled from the server

## [2.0.5](https://github.com/ngageoint/mage-ios-sdk/releases/tag/2.0.5) (06-20-2018)

##### Features

* Adds support for downloading GeoPackage layers from the server

##### Bug Fixes

* Fixes for oauth2 providers

## [2.0.4](https://github.com/ngageoint/mage-ios-sdk/releases/tag/2.0.4) (04-18-2018)

##### Bug Fixes

* When events are fetched and the connection fails, try to fetch the forms for all known events
  which could potentially work in an area of limited connectivity

## [2.0.3](https://github.com/ngageoint/mage-ios-sdk/releases/tag/2.0.3) (04-16-2018)

##### Bug Fixes

* Sends the app version on the authorize call

## [2.0.2](https://github.com/ngageoint/mage-ios-sdk/releases/tag/2.0.2) (04-13-2018)

##### Features

* Adds support for themes
* Improves disconnected login
* Adds login.gov support

## [2.0.1](https://github.com/ngageoint/mage-ios-sdk/releases/tag/2.0.1) (02-15-2018)

##### Features

* Additional information about phone network state and battery state are sent with locations

##### Bug Fixes

* Observation geometries are sent properly for location fields
* Archived forms are now filtered out when creating a new observation
* Location Services is not turned on in the case where the app restarts after a force stop
* Observation class uses the correct event not the current event
* Fix for location in forms

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
