# frozen_string_literal: true

module Helpers
  def partial(template, locals = {})
    erb(template, layout: false, locals: locals)
  end

  def google_auth
    @google_auth ||= GoogleAuth.new(request, session[:user_id])
  end

  def authenticate_lti
    if (lti_auth = LtiAuth.new(request)) && lti_auth.valid?
      session[:user_id] = params['custom_user_id']
    else
      logger.warn("LTI Authentication error: #{lti_auth.error}")
      error 401
    end
  end

  def authenticate_google
    halt erb(:'google_auth/authorize') unless session[:user_id] && google_auth.credentials
  end
end
