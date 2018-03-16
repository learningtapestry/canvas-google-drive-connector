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
* Redis

You must set an app on the `Google Developers Console` with access to the `Drive API`.
There you should get the credentials for `oauth2` to be used on this app.
Remember to set correctly the javascript origin and the callback url (the endpoint is: `<lti-app-url>/google-auth/callback`)

For configuring, first create your `.env` file:  `cp .env.template .env`
and then modify with your credentials (database, google app, redis, url, etc)

Install dependencies and create the database:
```
bundle install
bundle exec rake db:create db:migrate
```

For deploying (not development) you should also precompile assets:
`bundle exec rake assets:clean assets:precompile`

## Run

For running the server:
`ruby app.rb`

you can have an interactive console with the app configured and imported, using:
`bundle exec rake console`

## tests

uses Rspec: `bundle exec rspec`

you can check the coverage report on `coverage/index.html`

## LICENSE

This project is licensed under [GPL3](https://tldrlegal.com/license/gnu-general-public-license-v3-\(gpl-3\))
