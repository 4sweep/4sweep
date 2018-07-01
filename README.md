4sweep
======

4sweep is a Rails 3.2 web application for mass editing of Foursquare venues. It
is built on a concept of "flags" that can be submitted to the Foursquare API
v2. 4sweep supports the following flag types, which all operate on venues:

 * Edit Venue Details (name, address, contacts, etc)
 * Close Flag (event over, closed) and Re-Open
 * Delete Flag (inappropriate, does not exist) and Undelete
 * Make Private Flag
 * Change Categories (add, remove, replace all, with special home category flag)
 * Photo Flags
 * Tip Flags

Additionally, there is a rich Javascript based UI that makes generating hundreds
of flags feasible. The UI uses the Google Maps API v3.

Flags are submitted against the Foursquare API using a queue managed
by DelayedJob.

Current Status
--------------

4sweep is unmaintained as of March 2015.


Explorer Features
-----------------

 * Generate flags of any type quickly
 * Search based on:
   * Search term
   * Categories
   * Center point + radius
   * Bounding box
   * Mayorships of user
   * Recently created venues
 * Split large areas into smaller subareas
 * Filter venues using an advanced search BNF grammar

Flag Features
-------------
 * Flags can have comments
 * Can be checked to see if they were applied
 * Can be scheduled for a future date (through Delayed Job)

Configuration and setup
-----------------------

4sweep is currently built for Rails 3.2 and uses Bootstrap 2.0.  You will need
to install all required gems. It relies on a database supported by ActiveRecord,
and has only been tested with MySQL 5.5.

Additionally, you will need to install PEG.js, a JavaScript parser generator
library.  The easiest way to do this is via npm:

```shell
$ npm install pegjs
```
After installing PEG.js, make sure that it is executable on your command line:

```shell
$ pegjs -v
PEG.js 0.8.0
```

You only need PEG.js in your development environment. It is used as part of the
Rails asset pipeline to generate a javascript parser.

API credentials
----

4sweep needs you to specify a database in ``config/database.yml``.  

You will need to search globally for all instances of "REPLACE_ME".

4sweep depends on several external services.  IN ``config/application.yml``,
you will need to specify the following:

```yaml
development:
  # Your Foursquare API keys:
  app_id: ""
  app_secret: ""
  callback_url: ""

  # Optional, to support the Rake task of generating and publishing map icons:
  aws_key: ""
  aws_secret: ""
  s3_bucket: ""

  # Optional, for Cloudwatch monitoring of 4sweep in production
  cloudwatch_key: ""
  cloudwatch_secret: ""
```
