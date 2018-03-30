[![Known Vulnerabilities](https://snyk.io/test/github/learningtapestry/canvas-google-drive-connector/badge.svg?targetFile=Gemfile.lock)](https://snyk.io/test/github/learningtapestry/canvas-google-drive-connector?targetFile=Gemfile.lock)

# CanvasLMS / GoogleDrive integration

Simple [LTI](http://www.imsglobal.org/activity/learning-tools-interoperability) app for providing
google-drive integration into [CanvasLMS](http://canvaslms.com/)

Features:
- allow educators to link/embed gdrive files into course content
- allow students send gdrive files as part of assignment

## Getting Started

This app uses:
- Ruby 2.5.0 + Sinatra
- PostgreSQL 9.6
- Redis

You must create an app on the [Google Developer Console](https://console.developers.google.com).
- After creating the app, enable access to the Drive API for it
- Create credentials for the app
  - When asked where you will be calling the API from, select "Web server"
  - When asked what data you will be accessing, select "User data"
  - Under "Authorized Javascript origins" enter the URL where this app is deployed
  - Under "Authorized redirect URIs" enter the same URL as above, with `/google-auth/callback` at
    the end

This will give you the credentials for OAuth2 to be used in this app.

To configure this app with your new credentials, first create your `.env` file by running `cp
.env.template .env` and then modify with your new Google credentials:

```
SESSION_SECRET=[Generate a string here with SecureRandom.hex(32)]
GOOGLE_KEY=[Your Google client ID]
GOOGLE_SECRET=[Your Google client secret]
```

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

## API

### Config

- `/` [GET]
    - simple root endpoint (used mostly for smoke testing)
    - response: `plain/text` with the project name

- `/config.xml` [GET]
    - The LTI app configuration inside canvas is done via an XML document using the IMS Common Cartridge specification
    - https://www.imsglobal.org/cc/index.html.
    - response: `application/xml` with the config.

### Credentials management

- `/credentials/new` [GET]
    - render new credentials form

- `/credentials` [POST]
    - build new credentials pair and return to the user

### Google Oauth2

used internally

- `/google-auth` [GET]
    - Redirect to Google's authorization page if we don't have the credentials yet.

- `/google-auth/callback` [GET]
    - handle the callback from google after authorization

### LTI endpoints

All LTI launch requests are done via `POST`

- `/lti/gdrive-list` [POST]
    - Renders a google drive list.
    - This action is used internally on XHR requests, after we've accessed a LTI launch url.
    - authentication: `session user`, `google credentials` and `csrf token`
    -  Params:
       * `folder_id` : list the contents of this folder
       * `search_term` : term to search on the user's drive file names
       * `action` : which kind of action should be enabled when a file is selected

- `/lti/course-navigation` [POST]
    - Launch url for course navigation (tab shown on the course sidebar)
    - The *navigate* action just open the gdrive file in a new browser tab.
    - authentication: `lti request` and `google credentials`
    - Params: LTI Launch (http://www.imsglobal.org/specs/ltiv1p0/implementation-guide) from Canvas

- `/lti/editor-selection` [POST]
    - Launch url for editor selection (button inside the rich-text editor fields)
    - The *select* action shows the options for `link` or `embed` the file in the content.
    - authentication: `lti request` and `google credentials`
    - Params: LTI Launch (http://www.imsglobal.org/specs/ltiv1p0/implementation-guide) from Canvas

-`/lti/resource-selection` [POST]
    - Launch url for resource selection (module -> add item -> external tool)
    - The *link_resource* action generate a lti-link for the resource selected.
    - authentication: `lti request` and `google credentials`
    - Params: LTI Launch (http://www.imsglobal.org/specs/ltiv1p0/implementation-guide) from Canvas

-`/lti/link-selection` [POST]
    - Launch url for resource selection (module -> add item -> external tool)
    - The *link_resource* action generate a lti-link for the resource selected.
    - authentication: `lti request` and `google credentials`
    - `resource-selection` and `link-selection` are the same.
    - Params: LTI Launch (http://www.imsglobal.org/specs/ltiv1p0/implementation-guide) from Canvas

- `/lti/resources/:file_id` [POST]
    - Simple proxy for a drive document called from a LtiLinkItem.
    - authentication: `lti request`
    - Params:
        * file_id : the gdrive file id
        * LTI Launch (http://www.imsglobal.org/specs/ltiv1p0/implementation-guide) from Canvas

- `/lti/homework-submission` [POST]
    - Launch url for homework submission (tab on the assignment submission form)
    - The *submit* action generate a lti-link object (https://www.imsglobal.org/specs/lticiv1p0/specification-1).
    - This object is later used to embed an html snapshot of the file on the speed-grader.
    - authentication: `lti request` and `google credentials`
    - Params: LTI Launch (http://www.imsglobal.org/specs/ltiv1p0/implementation-guide) from Canvas

- `/lti/documents` [POST]
    - Generate an HTML snapshot of the google drive document
    - authentication: `session user`, `google credentials` and `csrf token`
    - Params:
       * file_id : the gdrive file id

- `/lti/documents/:file_id` [POST]
    - Renders the document snapshot HTML content for embeding on the speed-grader
    - Usually called from a `LtiLinkItem` object on Canvas.
    - authentication: `lti request`
    - Params:
       * file_id : the gdrive file id
       * LTI Launch (http://www.imsglobal.org/specs/ltiv1p0/implementation-guide) from Canvas


## LICENSE

This project is licensed under [GPL3](https://tldrlegal.com/license/gnu-general-public-license-v3-\(gpl-3\))
