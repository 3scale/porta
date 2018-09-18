module TestHelpers
  module Heroku

    def heroku_params
      {
        heroku_id: "app4242@kensa.heroku.com",
        plan: 'test',
        callback_url: 'http://localhost:7779/callback/999',
        logplex_token: nil,
        options: {}
      }
    end

    def raw_post(action, params, body)
      @request.env['RAW_POST_DATA'] = body
      response = post(action, params)
      @request.env.delete('RAW_POST_DATA')
      response
    end

    def raw_put(action, params, body)
      @request.env['RAW_POST_DATA'] = body
      response = put(action, params)
      @request.env.delete('RAW_POST_DATA')
      response
    end

    private

    def host!(domain)
      @request.host = domain
    end

    def http_login
      user = 'foo'
      pass = ::Heroku.password
      request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user,pass)
    end

    def prepare_master_account
      @partner = FactoryGirl.create(:partner, system_name: 'heroku', name: 'Heroku')
      service = master_account.default_service
      %w{blibli bloblo blabla}.each do |key|
        service.application_plans.create(name: key, system_name: key, partner: @partner)
      end
      master_account.account_plans.default!(master_account.account_plans.first)
      master_account.default_service.service_plans.default!(master_account.service_plans.first)
    end
  end
end
