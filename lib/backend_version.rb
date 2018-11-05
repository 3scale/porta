# frozen_string_literal: true

class BackendVersion < ActiveSupport::StringInquirer

  VERSIONS = { 'v1' => '1', 'v2' => '2', 'oauth' => 'oauth', 'oidc' => 'oidc' }.freeze
  private_constant :VERSIONS

  class << self

    VERSIONS.each_key do |method|
      define_method "#{method}_usable?" do |_|
        true
      end
      define_method "#{method}_visible?" do |_|
        true
      end
    end

    def oidc_usable?(_)
      false
    end

    def oidc_visible?(service)
      service.account.provider_can_use?(:apicast_oidc) &&
        (service.proxy || service.build_proxy).apicast_configuration_driven
    end

    def oauth_visible?(service)
      return true unless ThreeScale.config.onpremises
      service.backend_version.oauth? && !service.oidc?
    end

    def usable_versions(service:)
      VERSIONS.map do |method, name|
        name if public_send("#{method}_usable?", service)
      end.compact
    end

    def visible_versions(service:)
      service_visible_versions = {}

      VERSIONS.each do |method, name|
        if public_send("#{method}_visible?", service)
          service_visible_versions[locale(method)] = name
        end
      end

      service_visible_versions
    end

    def version_definition(name)
      locale(VERSIONS.key(name))
    end

    private

    def locale(key)
      I18n.t(key, scope: :authentication_options)
    end
  end

  VERSIONS.each do |method, name|
    define_method "#{method}?" do
      self == name
    end
  end

  def oidc?
    raise NotImplementedError, 'oidc? method is implemented on a service object'
  end

  def initialize(value)
    super(value.to_s) if value
  end

  def is?(*versions)
    versions.any? { |version| self == version.to_s }
  end

  def app_keys_allowed?
    self >= '2'
  end
end
