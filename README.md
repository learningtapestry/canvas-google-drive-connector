[![Known Vulnerabilities](https://snyk.io/test/github/learningtapestry/canvas-google-drive-connector/badge.svg?targetFile=Gemfile.lock)](https://snyk.io/test/github/learningtapestry/canvas-google-drive-connector?targetFile=Gemfile.lock)

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

## Run
- `ruby app.rb`

## tests

- uses Minitest
- `bundle exec rake test`

## LICENSE

This project is licensed under [GPL3](https://tldrlegal.com/license/gnu-general-public-license-v3-\(gpl-3\))
