module ApiDocs
  class AccountData

    def initialize(account)
      @account = account
    end

    def as_json(options = {})
      @account.nil? ? return_error : return_account_data
    end

    def account_data
      Hash[data_items.map{ |item| [item.to_sym, send(item)] }]
    end

    private

    def return_account_data
      { :status => 200,
        :results => account_data
      }
    end

    def name_with_service_name(app)
      "#{app.name} - #{app.service.name}"
    end

    def user_keys
      apps_with_backend_version(1).map do |app|
        { :name  => name_with_service_name(app),
          :value => app.user_key }
      end
    end

    def app_keys
      apps_with_backend_version(2, 'oauth').map do |app|
        { :name  => name_with_service_name(app),
          :value => app.keys.first || ''}
      end
    end

    def app_ids
      apps_with_backend_version(2, 'oauth').map do |app|
        { :name  => name_with_service_name(app),
          :value => app.application_id }
      end
    end

    def client_ids
      apps_with_backend_version('oauth').map do |app|
        { :name  => name_with_service_name(app),
          :value => app.application_id }
      end
    end

    def client_secrets
      apps_with_backend_version('oauth').map do |app|
        { :name  => name_with_service_name(app),
          :value => app.keys.first || ''}
      end
    end

    def return_error
      {:status => 401}
    end

    def apps_with_backend_version(*versions)
      apps.joins(:service).where.has { service.backend_version.in [*versions] }
    end

  end
end

