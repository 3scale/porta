module Heroku

  class SyncError < StandardError; end

  class << self

    def addon_name
      manifest['id']
    end

    def password
      manifest['api']['password']
    end

    def sso_salt
      manifest['api']['sso_salt']
    end

    def manifest
      @manifest ||= YAML.load_file("#{Rails.root}/config/heroku-addon.yml")
    end

    def sync(account)
      return false unless account.provider?

      heroku_id = account.settings.heroku_id
      return false if heroku_id.nil?

      clnt = HTTPClient.new
      auth  = Base64.strict_encode64("#{addon_name}:#{password}")
      response = clnt.get("https://api.heroku.com/vendor/apps/#{heroku_id}", {},  {'Authorization' => auth})

      case response.code
      when 200
        update_account!(account, response)
        Account.master.third_party_notifications!(account)
        account.first_admin.activate!
      when 404
        # everything is fine
      else
        raise SyncError
      end
    end

    def sso_url(account, return_to = nil)
      if account.heroku?
        settings = account.settings
        url = "https://api.heroku.com/myapps/#{settings.heroku_name}/addons/#{addon_name}"
        url << "?return_to=#{return_to}" unless return_to.nil?
        url
      else
        return false
      end
    end

    private

    def update_account!(account, response)
      hash = JSON.parse(response.body)
      user = account.first_admin
      user.email = hash['owner_email']
      user.save

      settings = account.settings
      settings.heroku_name = hash['name']
      settings.save

      account.classify
      account.save
    end
  end

  module ControllerMethods

    private

    def selected_plan
      if @selected_plan = application_plans.find_by_system_name(heroku_params[:plan])
        @selected_plan
      else
        free_plan
      end
    end

    def heroku_params
      JSON.parse(request.raw_post).symbolize_keys
    end

    def find_user_and_account
      @user = User.admins.find(params[:id])
      @account = @user.account
      unless @account.partner.try!(:system_name) == 'heroku'
        head(404)
        false
      else
        true
      end
    end

    def free_plan
      @free_plan ||= application_plans[0]
    end

    def application_plans
      @application_plans ||= partner.application_plans
    end

    def partner
      @partner ||= Partner.find_by_system_name('heroku')
    end

    def app_name
      heroku_params[:heroku_id].split('@')[0]
    end

    def create_heroku_account
      subdomain = app_name
      signup(subdomain)

      counter = 0
      while @account.errors[:subdomain].present? && counter < 10
        signup(subdomain + "-#{counter +=1 }")
      end

      # NOTE: Activation it's done after the sync of data
      HerokuWorker.sync(@account.id)
    end

    def signup(subdomain)
      Account.master.signup_provider(selected_plan, skip_third_party_notifications: true) do |account, user|
        @account, @user = account, user

        account.subdomain = subdomain
        account.org_name = "heroku-#{app_name}"
        account.sample_data = true
        account.settings.monthly_charging_enabled = false
        account.settings.heroku_id = heroku_params[:heroku_id]
        account.extra_fields['Signup_origin'] = 'heroku'
        account.extra_fields['partner'] = partner.system_name
        account.partner = partner

        user.signup_type = partner.signup_type
        user.password = user.password_confirmation = SecureRandom.hex
        user.email = heroku_params[:heroku_id]
      end
    end
  end

end
