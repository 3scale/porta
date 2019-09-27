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

  desc 'Update proxy rules owners'
  task update_proxy_rule_owners: :environment do
    puts 'Updating proxy rules owners...'
    duration = Benchmark.measure do
      progress = ProgressCounter.new(ProxyRule.count)
      ProxyRule.find_each do |proxy_rule|
        proxy_rule.update_columns(owner_id: proxy_rule.proxy_id, owner_type: 'Proxy') unless proxy_rule.owner_type?
        progress.call
      end
    end
    puts "Finished in #{format('%.1fs', duration.real)}\n\t"
  end
end
