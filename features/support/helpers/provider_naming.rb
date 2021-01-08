# frozen_string_literal: true

module ProviderNaming
  def provider_or_master_name
    @provider.master ? 'master' : @provider.domain
  end
end
