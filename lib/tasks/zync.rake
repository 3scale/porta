# frozen_string_literal: true

namespace :zync do
  namespace :resync do
    def each_with_progress(scope)
      total_count = scope.count
      batch_size = 100
      index = 0

      progress = -> do
        break unless (index % batch_size) == 0
        percent = (index / total_count.to_f) * 100.0
        puts "#{percent.round(2)}% completed"
      end

      scope.find_each(batch_size: batch_size) do |object|
        index += 1
        yield object
        progress.call
      end
    end

    desc 'Resync provider domains with zync'
    task provider_domains: :environment do
      accounts = Account.providers_with_master
      if (provider_id = ENV["PROVIDER_ID"])
        accounts = accounts.where(id: provider_id)
      end
      each_with_progress(accounts) { |account| Domains::ProviderDomainsChangedEvent.create_and_publish!(account) }
    end

    desc 'Resync proxy domains with zync'
    task proxy_domains: :environment do
      services = Service.includes(:proxy)
      if (provider_id = ENV["PROVIDER_ID"])
        services = services.where(account_id: provider_id)
      end
      each_with_progress(services) { |service| Domains::ProxyDomainsChangedEvent.create_and_publish!(service.proxy) }
    end

    desc 'Resync all domains with zync'
    task domains: [:provider_domains, :proxy_domains]
  end
end
