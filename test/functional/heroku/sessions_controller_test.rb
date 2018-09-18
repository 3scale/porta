require 'test_helper'

class Heroku::SessionsControllerTest < ActionController::TestCase
  include Heroku::ControllerMethods
  include TestHelpers::Heroku

  should route(:post, "http://#{master_account.domain}/heroku/sso").to action: 'create'

  def setup
    host! master_account.domain
    http_login
  end

  test 'post :create success' do
    data_for_create
    post :create, id: @user.id, timestamp: @timestamp, token: @token, "nav-data" => 'foo'

    assert_equal 'foo', cookies['heroku-nav-data']
    assert session[:heroku_sso]
  end

  test 'post :create should include return_to on the redirect' do
    data_for_create
    post :create, id: @user.id, timestamp: @timestamp, token: @token, "nav-data" => 'foo', return_to: '/foo/bar'
    assert_match(/&return_to=\/foo\/bar/, response.location)
  end

  test 'post :create should avoid erros for old users from heroku moved to standard plans' do
    data_for_create
    @account.partner = nil
    @account.save

    post :create, id: @user.id, timestamp: @timestamp, token: @token, "nav-data" => 'foo'
    assert_response 404
  end

  def data_for_create
    prepare_master_account
    create_heroku_account
    @timestamp = Time.now.to_i
    pre_token =  "#{@user.id}:#{Heroku.sso_salt}:#{@timestamp}"
    @token = Digest::SHA1.hexdigest(pre_token).to_s
  end
end
