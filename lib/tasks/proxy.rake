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
end
