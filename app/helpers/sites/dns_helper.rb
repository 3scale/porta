module Sites::DnsHelper
  def readonly_dns_domains?
    Rails.application.config.three_scale.readonly_custom_domains_settings
  end
end
