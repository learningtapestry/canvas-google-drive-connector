# frozen_string_literal: true

require_relative 'init'
require 'sinatra/activerecord/rake'
require 'sinatra/asset_pipeline/task'
require 'rake/testtask'
require 'rspec/core/rake_task'
# require_all 'tasks'

Sinatra::AssetPipeline::Task.define! Sinatra::Application

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = Dir.glob('spec/**/*_spec.rb')
  # t.rspec_opts = '--format documentation'
  # t.rspec_opts << ' more options'
  # t.rcov = true
end

task default: :spec

desc 'Boot up a console with required context'
task :console do
  require 'pry'
  require_relative 'init'
  Pry.start
end
