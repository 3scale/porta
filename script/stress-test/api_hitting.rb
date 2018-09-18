require 'pry' rescue nil
require 'httpclient'
require 'openssl'
require 'active_support/core_ext'
require 'securerandom'


class APIHitting
  delegate :get, :post, :put, :delete, :to => :@client

  def initialize(url, api_key)
    @url = url
    @api_key = api_key
    @client = Client.new(url + '/admin/api/', :provider_key => api_key)
  end

  def available_actions
    [ :list_apps, :list_accounts, :signup, :list_apps_per_account, :list_users_per_account, :create_app ]
  end

  def list_apps
    get('applications.xml')
  end

  def list_plans
    response = get('application_plans.xml')

    xml = Nokogiri::XML.parse(response.body)
    @plans = xml.css('/plans/plan/id').map do |node|
      node.text.to_i
    end

    response
  end

  def create_app
    list_accounts unless @accounts
    list_plans unless @plans

    plan = @plans.sample
    id = @accounts.sample

    post("accounts/#{id}/applications.xml", :name => "stress-app-#{SecureRandom.uuid}", :description => 'stress test', :plan_id => plan)
  end


  def list_apps_per_account
    list_accounts unless @accounts
    id = @accounts.sample
    get("accounts/#{id}/applications.xml")
  end

  def list_users_per_account
    list_accounts unless @accounts
    id = @accounts.sample
    get("accounts/#{id}/users.xml")
  end


  def list_accounts
    response = get('accounts.xml')

    xml = Nokogiri::XML.parse(response.body)
    @accounts = xml.css('/accounts/account/id').map do |node|
      node.text.to_i
    end

    response
  end

  def signup
    post('signup.xml', org_name: "stress-account-#{SecureRandom.uuid}",
                       email: "stress-email#{SecureRandom.uuid}@#{SecureRandom.uuid}.net",
                       username: "str-#{SecureRandom.uuid}",
                       password: 'stress-pwd')
  end

  def perform!
    action = available_actions.sample
    result = send(action)
    "#{self.class}: #{action} => #{result.try!(:status)}"
  end

  private

  class Client
    def initialize(root, defaults = {})
      @root = root
      @defaults = defaults
      @client = HTTPClient.new.tap do |client|
        client.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end

    def method_missing(method, url, params = {}, &block)
      start = Time.now
      @client.send(method, @root + url, @defaults.merge(params).to_query, &block)
    rescue HTTPClient::BadResponseError
      print "ERROR for #{method.to_s.upcase} #{url} with #{params.to_query} in #{Time.now - start} seconds\n"
    rescue HTTPClient::ReceiveTimeoutError
      print "TIMEOUT for #{method.to_s.upcase} #{url} with #{params.to_query} in #{Time.now - start} seconds\n"
    rescue OpenSSL::SSL::SSLError
      print "SSL ERROR #{method.to_s.upcase} #{url} with #{params.to_query} in #{Time.now - start} seconds\n"
    end
  end
end
