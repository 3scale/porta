# frozen_string_literal: true

require 'benchmark'
require 'progress_counter'

namespace :proxy do
  desc "create proxies for every service"
  task :create_proxies => :environment do
    Service.find_each do |s|
      puts "Creating proxy for #{s.account.name}"
      s.create_proxy unless s.proxy
    end
  end

  desc "rewrite the content types"
  task :rewrite_content_types => :environment do
    Proxy.update_all  "error_headers_over_limit = 'text/plain; charset=us-ascii'"
    Proxy.update_all  "error_headers_auth_failed = 'text/plain; charset=us-ascii'"
    Proxy.update_all  "error_headers_auth_missing = 'text/plain; charset=us-ascii'"
    Proxy.update_all  "error_headers_no_match = 'text/plain; charset=us-ascii'"
  end

  desc "rewrite api_endpoints"
  task :rewrite_endpoints => :environment do
    Proxy.find_each do |p|
      schema = p.endpoint.gsub(/http:\/\//, '')
      schema = schema.gsub(/:80/,'')
      if schema =~ /[^A-Za-z\d.+-]/
        schema =  schema.gsub(/[^A-Za-z\d.+-]/, '-')
        p.endpoint = "http://#{schema}:80"
        p.save
      end
    end
  end

  desc 'Fixing nil endpoint for hosted'
  task :set_correct_endpoint_hosted => :environment do
    Service.includes(:proxy).where(proxies: {endpoint: nil}, deployment_option: 'hosted').find_each(&:deployment_option_changed)
  end

  desc 'Resets proxy config tracking object'
  task :reset_config_change_history, [:account_id] => :environment do |_, args|
    account_id = args[:account_id]
    collection = account_id ? Account.providers_with_master.find_by(id: account_id)&.proxies : Proxy.all

    return unless collection

    reset_date = Time.utc(1900, 1, 1).freeze
    progress = ProgressCounter.new(collection.count)

    collection.find_in_batches do |proxies|
      proxies.each do |proxy|
        tracking_object = proxy.affecting_change_history
        progress.call
        next if tracking_object.created_at != tracking_object.updated_at
        tracking_object.update_column(:updated_at, reset_date)
      end
      sleep(0.5) unless Rails.env.test?
    end
  end

  desc 'Migrate to services to configuration driven'
  task :migrate_to_configuration_driven, %i[services_selector update_endpoints] => :environment do |_, args|
    services_selectors = args[:services_selector].to_s.split(',')   # <id>(,<id>)* | hosted | self_managed | nil
    deployment_option = services_selectors.delete('hosted') || services_selectors.delete('self_managed') || Service::DeploymentOption.gateways
    service_ids = services_selectors - %w[hosted self_managed]

    update_endpoints = ActiveModel::Type::Boolean.new.deserialize(args[:update_endpoints].presence)
    update_method = update_endpoints ? :update_attribute : :update_column

    services = Service.accessible.where(deployment_option: deployment_option, account: Account.providers.without_deleted).where(service_ids.present? ? { id: service_ids } : {})
    proxies = Proxy.where(apicast_configuration_driven: false, service: services)

    progress = ProgressCounter.new(proxies.count)

    proxies.find_in_batches do |group|
      group.each do |proxy|
        Proxy.transaction do
          proxy.public_send(update_method, :apicast_configuration_driven, true)
          progress.call

          next unless proxy.deployed_at
          ProxyDeploymentService.call(proxy, environment: :staging)

          production_deployed_at = proxy.provider.hosted_proxy_deployed_at
          next if production_deployed_at.blank? || production_deployed_at < proxy.created_at
          ProxyDeploymentService.call(proxy, environment: :production)
        end
      end
      sleep(0.2) unless Rails.env.test?
    end
  end
end
