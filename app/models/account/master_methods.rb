module Account::MasterMethods
  extend ActiveSupport::Concern

  included do
    include Logic::ProviderSignup::Master

    has_many :provider_accounts, -> { providers }, :class_name  => 'Account', :foreign_key => 'provider_account_id'
    alias_method :providers, :provider_accounts

    scope :by_provider_key, lambda { |provider_key|
      includes(:bought_cinstances).references(:bought_cinstances).merge(Cinstance.by_user_key(provider_key))
    }

    before_destroy :avoid_destroy_of_master_account

    def avoid_destroy_of_master_account
      # Should return false if master
      !master?
    end

    def master_on_premises?
      master? && ThreeScale.config.onpremises
    end
  end

  module ClassMethods
    def find_by_provider_key(provider_key)
      by_provider_key(provider_key).first
    end

    def find_by_provider_key!(provider_key)
      find_by_provider_key(provider_key) || raise(Backend::ProviderKeyInvalid)
    end
  end
end
