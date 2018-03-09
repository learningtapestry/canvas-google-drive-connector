# frozen_string_literal: true

module AppHelpers
  def authenticate!(methods = [])
    methods.each { |method| send :"authenticate_#{method}" }
  end

  def authenticate_lti
    if (lti_auth = LtiAuth.new(request)) && lti_auth.valid?
      session[:user_id] = params['custom_user_id']
      session[:return_url] = params['content_item_return_url']
    else
      logger.warn("LTI Authentication error: #{lti_auth.error}")
      error 401, lti_auth.error
    end
  end

  def authenticate_google
    halt erb(:'google_auth/authorize') unless session[:user_id] && google_auth.credentials
  end

  def google_auth
    @google_auth ||= GoogleAuth.new(request, session[:user_id])
  end

  def partial(template, locals = {})
    erb(template, layout: false, locals: locals)
  end

  def self.url_for(path, full: false)
    @base_url ||= ENV.fetch('LTI_APP_URL')
    root_path = full ? @base_url : URI.parse(@base_url).path
    File.join(root_path, path)
  end

  def url_for(path, full: false)
    AppHelpers.url_for path, full: full
  end
end
