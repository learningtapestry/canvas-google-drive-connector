# frozen_string_literal: true

class SubmissionContext
  attr_reader :user_id, :context

  def initialize(user_id, params)
    @user_id = user_id
    @context = params.slice(
      :tool_consumer_instance_guid, :context_title, :custom_domain, :custom_user_id,
      :lis_person_name_full, :ext_lti_assignment_id
    ).merge(submission: 'homework')
  end

  def fetch
    value = AppHelpers.redis.get(key)
    JSON.parse(value) if value.present?
  end

  def key
    prefix = testing? ? '_lti_test' : 'lti'
    "#{prefix}:context:#{user_id}"
  end

  def store
    AppHelpers.redis.set(key, context.to_json, ex: 2.hour.to_i)
  end

  def testing?
    ENV['RACK_ENV'] == 'test'
  end
end
