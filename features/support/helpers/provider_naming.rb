module ProviderNaming
  def provider_or_master_name
    @provider.master ? 'master' : @provider.internal_domain
  end
end
