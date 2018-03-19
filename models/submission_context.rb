# frozen_string_literal: true

#
# Store context for assignments and homework submission.
#
class SubmissionContext
  CONTEXT_PROPERTIES = %i(
    tool_consumer_instance_guid
    context_title
    custom_domain
    custom_user_id
    lis_person_name_full
    ext_lti_assignment_id
  ).freeze

  #
  # Params:
  #   - user_id: canvas user id
  #   - params: rack request params
  #
  def initialize(user_id, params)
    @user_id = user_id
    @params = params
  end

  def fetch
    value = AppHelpers.redis.get(key)
    JSON.parse(value) if value.present?
  end

  def save
    AppHelpers.redis.set(key, context.to_json, ex: 2.hour.to_i)
  end

  private

  def context
    @context ||= @params.slice(*CONTEXT_PROPERTIES).merge(submission: 'homework')
  end

  def key
    prefix = testing? ? '_lti_test' : 'lti'
    "#{prefix}:context:#{@user_id}"
  end

  def testing?
    ENV['RACK_ENV'] == 'test'
  end
end
