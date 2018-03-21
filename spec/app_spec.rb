# frozen_string_literal: true

require_relative 'spec_helper'

describe 'root' do
  before { get '/' }

  it { expect(last_response).to be_ok }
end

describe 'config' do
  before { get '/config.xml' }

  it { expect(last_response).to be_ok }
  it { expect(last_response.content_type).to include('application/xml') }
  it 'has a launch_url' do
    config = Nokogiri::XML(last_response.body)
    expect(config.at_xpath('//blti:launch_url')).to be_present
  end
end

describe 'credentials' do
  it 'renders a generate credentials buttons' do
    get '/credentials/new'
    expect(last_response).to have_css('.credentials-generate-btn')
  end

  it 'generates new credentials' do
    expect { post '/credentials' }.to change { AuthCredential.count }.by(1)
    credential = Nokogiri::HTML(last_response.body).css('.credential-value').first
    expect(credential).to be_present
    expect(credential.text).to eq AuthCredential.last.key
  end
end

describe 'LTI authentication' do
  it 'requires a valid key/secret pair' do
    post '/lti/course-navigation'
    expect(last_response.status).to eq 401
    expect(last_response.body).to include('No key/pair credentials for')
  end

  it 'requires an valid oauth signature' do
    lti_request '/lti/course-navigation', signature: 'wrong-signature'
    expect(last_response.status).to eq 401
    expect(last_response.body).to include('Invalid Signature')
  end

  it 'expires the timestamp in 5 minutes' do
    lti_request '/lti/course-navigation', timestamp: (Time.current - 5.minutes).to_i
    expect(last_response.status).to eq 401
    expect(last_response.body).to include('Timestamp expired')
  end

  it 'set session user when request is valid' do
    lti_request '/lti/course-navigation'
    expect(last_response).to be_ok
    expect(session['user_id']).to eq 'user-id'
  end
end

describe 'googleauth' do
  it 'redirect to google authorization when do not have credentials' do
    get '/google-auth'
    expect(last_response).to be_redirect
    follow_redirect!
    expect(last_request.url).to start_with('https://accounts.google.com/o/oauth2/auth')
  end

  it 'callback and render success' do
    expect(Google::Auth::WebUserAuthorizer).to receive(:handle_auth_callback_deferred)
    get '/google-auth/callback'
    expect(last_response).to be_ok
    expect(last_response).to have_css('.googleauth.success')
  end
end

describe 'gdrive-list' do
  it 'render gdrivelist partial' do
    allow_any_instance_of(GoogleAuth).to receive(:credentials).and_return(OpenStruct.new)
    allow_any_instance_of(Google::Apis::DriveV3::DriveService).to receive(:list_files).and_return(
      OpenStruct.new(files: [OpenStruct.new(id: '1234', name: 'my-file')])
    )
    post '/lti/gdrive-list', { action: :select }, 'rack.session' => { user_id: 'user-id' }
    expect(last_response).to be_ok
  end
end

describe 'course-navigation' do
  it 'authenticates oauth LTI requests' do
    lti_request '/lti/course-navigation'
    expect(last_response).to be_ok
  end

  it 'render file-browser component when is authorized on google' do
    allow_any_instance_of(GoogleAuth).to receive(:credentials).and_return(OpenStruct.new)
    lti_request '/lti/course-navigation'
    expect(last_response).to have_css('.file-browser')
    component = Nokogiri::HTML(last_response.body).css('.file-browser').first
    expect(component.attr('data-action')).to eq 'navigate'
  end
end

describe 'editor-selection' do
  it 'authenticates oauth LTI requests' do
    lti_request '/lti/editor-selection'
    expect(last_response).to be_ok
  end

  it 'render file-browser component when is authorized on google' do
    allow_any_instance_of(GoogleAuth).to receive(:credentials).and_return(OpenStruct.new)
    lti_request '/lti/editor-selection'
    expect(last_response).to have_css('.file-browser')
    component = Nokogiri::HTML(last_response.body).css('.file-browser').first
    expect(component.attr('data-action')).to eq 'select'
  end
end

describe 'resource-selection' do
  it 'authenticates oauth LTI requests' do
    lti_request '/lti/resource-selection'
    expect(last_response).to be_ok
  end

  it 'render file-browser component when is authorized on google' do
    allow_any_instance_of(GoogleAuth).to receive(:credentials).and_return(OpenStruct.new)
    lti_request '/lti/resource-selection'
    expect(last_response).to have_css('.file-browser')
    component = Nokogiri::HTML(last_response.body).css('.file-browser').first
    expect(component.attr('data-action')).to eq 'link_resource'
  end
end

describe 'link-selection' do
  it 'authenticates oauth LTI requests' do
    lti_request '/lti/link-selection'
    expect(last_response).to be_ok
  end

  it 'render file-browser component when is authorized on google' do
    allow_any_instance_of(GoogleAuth).to receive(:credentials).and_return(OpenStruct.new)
    lti_request '/lti/link-selection'
    expect(last_response).to have_css('.file-browser')
    component = Nokogiri::HTML(last_response.body).css('.file-browser').first
    expect(component.attr('data-action')).to eq 'link_resource'
  end
end

describe 'homework-submission' do
  it 'authenticates oauth LTI requests' do
    lti_request '/lti/homework-submission'
    expect(last_response).to be_ok
  end

  it 'render file-browser component when is authorized on google' do
    allow_any_instance_of(GoogleAuth).to receive(:credentials).and_return(OpenStruct.new)
    lti_request '/lti/homework-submission'
    expect(last_response).to have_css('.file-browser')
    component = Nokogiri::HTML(last_response.body).css('.file-browser').first
    expect(component.attr('data-action')).to eq 'submit'
  end

  it 'store context on redis' do
    allow_any_instance_of(GoogleAuth).to receive(:credentials).and_return(OpenStruct.new)
    lti_request '/lti/homework-submission'
    value = AppHelpers.redis.get('_lti_test:context:user-id')
    expect(value).to_not be_nil
    expect(JSON.parse(value)['context_title']).to eq 'GDrive test'
  end
end

describe 'documents' do
  before do
    allow_any_instance_of(GoogleAuth).to receive(:credentials).and_return(OpenStruct.new)
    lti_request '/lti/homework-submission'
  end

  def mock_file
    service = Google::Apis::DriveV3::DriveService
    file_id = SecureRandom.hex(8)
    allow_any_instance_of(service).to receive(:get_file).and_return OpenStruct.new(id: file_id)
    allow_any_instance_of(service).to receive(:export_file).and_return OpenStruct.new(string: 'file-content')
    file_id
  end

  it 'renders content-submission' do
    post '/lti/documents', file_id: mock_file

    expect(last_response).to be_ok
    expect(last_response).to have_css('.content-submission')
  end

  it 'create a document object' do
    file_id = mock_file
    post '/lti/documents', file_id: file_id

    document = Document.last
    expect(document.file_id).to eq file_id
    expect(document.content).to eq 'file-content'
  end
end
