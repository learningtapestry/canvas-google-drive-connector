# frozen_string_literal: true

require_relative 'init'
require 'sinatra/activerecord/rake'
require 'sinatra/asset_pipeline/task'
require 'rake/testtask'
# require_all 'tasks'

Sinatra::AssetPipeline::Task.define! Sinatra::Application

Rake::TestTask.new do |t|
  t.pattern = 'tests/**/*_test.rb'
  # SKIP = [].freeze # skip special case tests that need a specific binary tool
  # t.test_files = FileList['tests/**/*_test.rb'] - SKIP
  t.warning = false
end

desc 'Boot up a console with required context'
task :console do
  require 'pry'
  require_relative 'init'
  Pry.start
end
