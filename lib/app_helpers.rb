# frozen_string_literal: true

#
# Helper methods are available on actions and views
#
module AppHelpers
  #
  # Calls a chain of authentication methods.
  # Params:
  #   - methods : List of symbols for each specific authentication methods (e.g: :google, :lti)
  #
  def authenticate!(methods = [])
    methods.each { |method| send :"authenticate_#{method}" }
  end

  #
  # Authenticate LTI requests.
  # When the request is valid we set `user` and `return_url` on the session for further use,
  # so this usually is the first method on the chain.
  #
  def authenticate_lti
    if (lti_auth = LtiAuth.new(request)) && lti_auth.valid?
      session[:user_id] = params['custom_user_id']
      session[:return_url] = params['content_item_return_url']
    else
      logger.warn("LTI Authentication error: #{lti_auth.error}")
      error 401, lti_auth.error
    end
  end

  #
  # Check for Google credentials, otherwise show an authorize page.
  # For this to work we must have a session user set
  #
  def authenticate_google
    halt erb(:'google_auth/authorize') unless user_id && google_auth.credentials
  end

  #
  # Check if we have a session user set (usually from the lti authentication).
  #
  def authenticate_user
    error 401, 'No session user' unless user_id
  end

  #
  # Google authentication instance helper
  #
  def google_auth
    @google_auth ||= GoogleAuth.new(request, user_id)
  end

  #
  # Render an ERB partial template, without layout.
  # Params:
  #   - template: symbol with the template path/name (relative to the views fiolder)
  #   - locals: hash for local variables available on the partial
  #
  def partial(template, locals = {})
    erb(template, layout: false, locals: locals)
  end

  #
  # Redis singleton instance.
  # Usage: `AppHelpers.redis.<redis-method>`
  #
  def self.redis
    @redis ||= Redis.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379'))
  end

  #
  # Redis accessor for actions and views
  #
  def redis
    AppHelpers.redis
  end

  def search_term
    params[:search_term].presence
  end

  #
  # URL builder, used for taking into account deploys with a nested path.
  # Params:
  #   - path: url path relative to the root.
  #   - full: wether we should build only the path or the full url with domain and all (default: false).
  #
  def self.url_for(path, full: false)
    @base_url ||= ENV.fetch('LTI_APP_URL')
    root_path = full ? @base_url : URI.parse(@base_url).path
    File.join(root_path, path)
  end

  #
  # URL builder accessor for actions and views.
  #
  def url_for(path, full: false)
    AppHelpers.url_for path, full: full
  end

  def user_id
    session[:user_id].presence
  end
end
