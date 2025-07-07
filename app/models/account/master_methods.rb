module Account::MasterMethods
  extend ActiveSupport::Concern

  included do
    include Logic::ProviderSignup::Master

    has_many :provider_accounts, -> { providers }, :class_name  => 'Account', :foreign_key => 'provider_account_id'
    alias_method :providers, :provider_accounts

    scope :by_provider_key, ->(provider_key) {
      joins(:bought_cinstances).where(cinstances: { user_key: provider_key })
    }

    scope :by_service_token, ->(service_token) {
      joins(:service_tokens).where(service_tokens: { value: service_token })
    }

    before_destroy :avoid_destroy_of_master_account

    def avoid_destroy_of_master_account
      # Should return false if master
      throw :abort if master?
    end

    def master_on_premises?
      master? && ThreeScale.config.onpremises
    end
  end

  module ClassMethods
    def find_by_service_token!(service_token, error: ActiveRecord::RecordNotFound)
      by_service_token(service_token).take || raise(error)
    end

    def first_by_provider_key(provider_key)
      by_provider_key(provider_key).take
    end

    def first_by_provider_key!(provider_key, error: Backend::ProviderKeyInvalid)
      first_by_provider_key(provider_key) || raise(error)
    end
  end
end
