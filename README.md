# CanvasLMS / GoogleDrive integration

Simple [LTI](http://www.imsglobal.org/activity/learning-tools-interoperability) app for providing google-drive integration into [CanvasLMS](http://canvaslms.com/)

Features:
- allow educators to link/embed gdrive files into course content
- allow students send gdrive files as part of assignment

## Getting Started

This app uses:
* Ruby 2.5.0 + Sinatra
* `PostgreSQL 9.6`

For setting up first create your `.env` file:  `cp .env.template .env`
and then modify with your credentials

This is a simple service API, use by UnboundEd, for data retrieval and
indexing of components.

* Ruby 2.3.1 + Sinatra
* `PostgreSQL 9.4`
* `ElasticSearch >=2.2.0`

## Run
- `ruby app.rb`

## tests

- uses Minitest
- `bundle exec rake test`

## LICENSE

This project is licensed under [GPL3](https://tldrlegal.com/license/gnu-general-public-license-v3-\(gpl-3\))
