# frozen_string_literal: true

require 'rack'
require 'rack/contrib'
require './app'

use Rack::PostBodyContentTypeParser
run Sinatra::Application
