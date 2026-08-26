# frozen_string_literal: true

namespace :zync do
  namespace :resync do
    def each_with_progress(label, scope)
      puts "== Resyncing #{label} =="
      total_count = scope.count
      index = 0

      step = [(total_count / 10), 1].max
      progress = -> do
        break unless (index % step).zero?

        percent = (index / total_count.to_f) * 100.0
        puts "#{percent.round(2)}% completed"
      end

      scope.find_each(batch_size: 100) do |object|
        index += 1
        yield object
        progress.call
      end
    end

    def target_providers
      accounts = Account.providers_with_master
      accounts = accounts.where(id: ENV["PROVIDER_ID"]) if ENV["PROVIDER_ID"]
      accounts
    end

    desc 'Resync provider domains with zync'
    task providers: :environment do
      each_with_progress('providers', target_providers) { |account| ZyncResyncEvent.create_and_publish!(account, provider_id: account.id) }
    end

    task provider_domains: :providers

    desc 'Resync services with zync'
    task services: :environment do
      services = Service.joins(:account).merge(target_providers)
      each_with_progress('services', services) { |service| ZyncResyncEvent.create_and_publish!(service, provider_id: service.account_id) }
    end

    desc 'Resync proxy domains with zync'
    task proxies: :environment do
      proxies = Proxy.eager_load(:service).joins(service: :account).merge(target_providers)
      each_with_progress('proxies', proxies) { |proxy| ZyncResyncEvent.create_and_publish!(proxy, provider_id: proxy.service.account_id, service_id: proxy.service_id) }
    end

    task proxy_domains: :proxies

    desc 'Resync applications with zync'
    task applications: :environment do
      cinstances = Cinstance.eager_load(:service).joins(service: :account).merge(target_providers)
      each_with_progress('applications', cinstances) { |cinstance| ZyncResyncEvent.create_and_publish!(cinstance, provider_id: cinstance.service.account_id, service_id: cinstance.service_id) }
    end

    desc 'Resync all domains with zync'
    task domains: %i[provider_domains proxy_domains]

    desc 'Full resync'
    task full: %i[providers services proxies applications]
  end
end
