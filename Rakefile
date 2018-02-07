# frozen_string_literal: true

require_relative 'init'

require 'sinatra/activerecord/rake'
require 'rake/testtask'

# require_all 'tasks'

Rake::TestTask.new do |t|
  # t.pattern = 'tests/**/*_test.rb'

  # skip special case tests that need a specific binary tool
  SKIP = [].freeze
  t.test_files = FileList['tests/**/*_test.rb'] - SKIP
  t.warning = false
end

desc 'Boot up a console with required context'
task :console do
  require 'pry'
  require_relative 'init'
  Pry.start
end
