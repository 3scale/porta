require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

class Authentication::Strategy::CasTest < ActiveSupport::TestCase

  def setup
    @provider = Factory :provider_account
    @provider.settings.update_attribute :cas_server_url, "http://palomit.as"

    @account  = Factory :buyer_account, :provider_account => @provider
    @strategy = Authentication::Strategy::Cas.new @provider
  end

  test "basic cas setup" do
    provider = Factory :provider_account
    strategy = Authentication::Strategy::Cas.new provider

    assert_raise StandardError do
      strategy.login_url
    end

    assert strategy.service =~ /#{provider.domain}/

  end

  test "authenticate falls back to internal strategy" do
    user = Factory :user, :account  => @account,
                          :username => 'dave',
                          :password => 'kangaroo'
    user.activate!

    assert_equal user,
      @strategy.authenticate(:username => 'dave', :password => 'kangaroo')
  end

  test "authenticate a user with cas" do
    user = Factory :user, :account  => @account, :cas_identifier => "kongaroo"
    user.activate!

    assert_equal user,
      authenticate_with_cas(user)
  end

  test "can't authenticate if validate fails" do
    response = stub :body => "yes", :code => 422
    HTTPClient.expects(:get).with(@strategy.validate_url_with_query("made-up")).returns(response)
    assert !@strategy.authenticate(:ticket => "made-up")

    response = stub :body => "no", :code => 200
    HTTPClient.expects(:get).with(@strategy.validate_url_with_query("made-up")).returns(response)
    assert !@strategy.authenticate(:ticket => "made-up")

    response = stub :body => "yes", :code => 200
    HTTPClient.expects(:get).with(@strategy.validate_url_with_query("made-up")).returns(response)
    assert !@strategy.authenticate(:ticket => "made-up")
  end

  test "can't authenticate if the user cannot login" do
    user = Factory :user, :account  => @account, :cas_identifier => "kongaroo"
    assert !authenticate_with_cas(user)
  end

  private
    def authenticate_with_cas user
      response = stub :body => "yes\n#{user.cas_identifier}", :code => 200
      HTTPClient.expects(:get).with(@strategy.validate_url_with_query("made-up")).returns(response)

      @strategy.authenticate :ticket => "made-up"
    end

end
