require 'hashie/mash'

module Apicast
  class UserSource
    attr_reader :provider, :user

    def initialize(user)
      @user = user
      @provider = user.account
    end

    def reload
      @user.reload
      @provider.reload
      self
    end

    delegate :services, :provider_key, :id, to: :mash

    def attributes_for_proxy
      provider_attributes.merge('services' => user_attributes.fetch('accessible_services'))
    end

    protected

    def provider_attributes
      options = {
        root: false,
        only: [:id],
        methods: [:provider_key]
      }

      provider.as_json(options)
    end

    def user_attributes
      options = {
        root: false,
        only: [],
        include: [
          accessible_services: Apicast::ProviderSource::SERVICE_SERIALIZE_OPTIONS.dup
        ]
      }

      user.as_json(options)
    end

    def mash
      Hashie::Mash.new(attributes_for_proxy)
    end
  end
end
