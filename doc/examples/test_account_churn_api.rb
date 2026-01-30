#!/usr/bin/env ruby
# frozen_string_literal: true

# Test script for creating and deleting 3scale accounts via API to test account churn
#
# Usage:
#   ruby test_account_churn_api.rb
#
# Environment variables:
#   THREESCALE_BASE_URL - Base URL of the 3scale instance (e.g., https://your-instance-admin.3scale.net)
#   THREESCALE_ACCESS_TOKEN - Access token for API authentication
#   CHURN_ITERATIONS - Number of times to repeat the create/delete cycle (default: 10)
#   VERBOSE - Set to 'true' for detailed output (default: false)

require 'net/http'
require 'uri'
require 'json'
require 'openssl'

class ThreeScaleChurnTest
  attr_reader :base_url, :access_token, :iterations, :verbose

  def initialize(base_url:, access_token:, iterations: 10, verbose: false)
    @base_url = base_url.chomp('/')
    @access_token = access_token
    @iterations = iterations
    @verbose = verbose
    @stats = {
      created: 0,
      deleted: 0,
      failed_creates: 0,
      failed_deletes: 0,
      no_applications: 0,
      with_applications: 0,
      proxy_calls_success: 0,
      proxy_calls_failed: 0
    }
  end

  def run
    puts "Starting 3scale Account Churn Test"
    puts "Base URL: #{base_url}"
    puts "Iterations: #{iterations}"
    puts "=" * 80

    start_time = Time.now

    iterations.times do |i|
      iteration_num = i + 1
      puts "\n[#{iteration_num}/#{iterations}] Starting iteration..."

      account_id = create_account(iteration_num)

      if account_id
        applications = check_applications(account_id)

        # Make proxy calls for each application
        applications.each do |app|
          next unless app[:user_key] && app[:service_id]

          staging_endpoint = get_service_proxy(app[:service_id])
          if staging_endpoint
            make_proxy_call(staging_endpoint, app[:user_key])
          end
        end

        delete_account(account_id)
      else
        puts "  ✗ Skipping application check and deletion due to creation failure"
      end

      sleep 0.5 # Small delay between iterations
    end

    end_time = Time.now
    duration = end_time - start_time

    print_summary(duration)
  end

  private

  def create_account(iteration)
    timestamp = Time.now.to_i
    random_suffix = rand(36**4).to_s(36).rjust(4, '0')
    org_name = "TestOrg#{iteration}_#{timestamp}_#{random_suffix}"
    username = "testuser#{iteration}_#{timestamp}_#{random_suffix}"
    email = "test#{iteration}_#{timestamp}_#{random_suffix}@example.com"
    password = "Password123!"

    log "Creating account: #{org_name}"

    uri = URI("#{base_url}/admin/api/signup.json")
    uri.query = URI.encode_www_form('access_token' => access_token)

    params = {
      'org_name' => org_name,
      'username' => username,
      'email' => email,
      'password' => password
    }

    response = make_request(uri, :post, params)

    if response.is_a?(Net::HTTPSuccess)
      account_id = extract_account_id(response.body)
      if account_id
        @stats[:created] += 1
        puts "  ✓ Account created successfully (ID: #{account_id})"
        account_id
      else
        @stats[:failed_creates] += 1
        puts "  ✗ Failed to extract account ID from response"
        log_response(response)
        nil
      end
    else
      @stats[:failed_creates] += 1
      puts "  ✗ Account creation failed (HTTP #{response.code})"
      log_response(response)
      nil
    end
  rescue StandardError => e
    @stats[:failed_creates] += 1
    puts "  ✗ Exception during account creation: #{e.message}"
    log e.backtrace.join("\n") if verbose
    nil
  end

  def check_applications(account_id)
    log "Checking applications for account #{account_id}"

    uri = URI("#{base_url}/admin/api/accounts/#{account_id}/applications.json")
    uri.query = URI.encode_www_form('access_token' => access_token)

    response = make_request(uri, :get)

    if response.is_a?(Net::HTTPSuccess)
      applications = extract_applications(response.body)

      if applications.any?
        @stats[:with_applications] += 1
        puts "  ✓ Found #{applications.size} application(s)"
        if verbose
          applications.each do |app|
            puts "    - App ID: #{app[:id]}, Name: #{app[:name]}, State: #{app[:state]}"
          end
        end
      else
        @stats[:no_applications] += 1
        puts "  ℹ No applications found in account"
      end

      applications
    else
      puts "  ✗ Failed to check applications (HTTP #{response.code})"
      log_response(response)
      []
    end
  rescue StandardError => e
    puts "  ✗ Exception during application check: #{e.message}"
    log e.backtrace.join("\n") if verbose
    []
  end

  def get_service_proxy(service_id)
    log "Getting proxy configuration for service #{service_id}"

    uri = URI("#{base_url}/admin/api/services/#{service_id}/proxy.json")
    uri.query = URI.encode_www_form('access_token' => access_token)

    response = make_request(uri, :get)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      staging_endpoint = data.dig('proxy', 'sandbox_endpoint')

      if staging_endpoint
        puts "  ✓ Found staging endpoint: #{staging_endpoint}"
        staging_endpoint
      else
        puts "  ✗ No staging endpoint found in proxy configuration"
        log_response(response)
        nil
      end
    else
      puts "  ✗ Failed to get proxy configuration (HTTP #{response.code})"
      log_response(response)
      nil
    end
  rescue StandardError => e
    puts "  ✗ Exception getting proxy configuration: #{e.message}"
    log e.backtrace.join("\n") if verbose
    nil
  end

  def make_proxy_call(endpoint, user_key)
    log "Making proxy call to #{endpoint} with user_key #{user_key}"

    # Generate 1MB payload
    payload = { data: 'A' * (1024) }.to_json

    uri = URI(endpoint)
    uri.query = URI.encode_www_form('user_key' => user_key)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl?
    http.read_timeout = 30
    http.open_timeout = 30

    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request.body = payload

    log "POST #{uri}"
    log "Payload size: #{payload.bytesize} bytes"
    response = http.request(request)
    if response.is_a?(Net::HTTPSuccess)
      @stats[:proxy_calls_success] += 1
      puts "  ✓ Proxy call successful (HTTP #{response.code})"
    else
      @stats[:proxy_calls_failed] += 1
      puts "  ✗ Proxy call failed (HTTP #{response.code})"
      log_response(response)
    end
  rescue StandardError => e
    @stats[:proxy_calls_failed] += 1
    puts "  ✗ Exception during proxy call: #{e.message}"
    log e.backtrace.join("\n") if verbose
  end

  def delete_account(account_id)
    log "Deleting account #{account_id}"

    uri = URI("#{base_url}/admin/api/accounts/#{account_id}.json")
    uri.query = URI.encode_www_form('access_token' => access_token)

    response = make_request(uri, :delete)

    if response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPNoContent)
      @stats[:deleted] += 1
      puts "  ✓ Account deleted successfully"
    else
      @stats[:failed_deletes] += 1
      puts "  ✗ Account deletion failed (HTTP #{response.code})"
      log_response(response)
    end
  rescue StandardError => e
    @stats[:failed_deletes] += 1
    puts "  ✗ Exception during account deletion: #{e.message}"
    log e.backtrace.join("\n") if verbose
  end

  def make_request(uri, method, params = nil)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl?
    http.read_timeout = 30
    http.open_timeout = 30

    request = case method
              when :get
                Net::HTTP::Get.new(uri)
              when :post
                req = Net::HTTP::Post.new(uri)
                if params
                  req['Content-Type'] = 'application/json'
                  req.body = params.to_json
                end
                req
              when :delete
                Net::HTTP::Delete.new(uri)
              else
                raise "Unsupported HTTP method: #{method}"
              end

    log "#{method.to_s.upcase} #{uri}"
    log "Params: #{params.inspect}" if params && verbose

    http.request(request)
  end

  def extract_account_id(json_body)
    data = JSON.parse(json_body)
    data.dig('account', 'id')&.to_i
  rescue StandardError => e
    log "Error parsing account ID from JSON: #{e.message}"
    nil
  end

  def extract_applications(json_body)
    data = JSON.parse(json_body)
    apps_array = data['applications'] || []

    apps_array.map do |app|
      app = app['application']
      {
        id: app['id'],
        name: app['name'],
        state: app['state'],
        user_key: app.dig('user_key'),
        plan_id: app.dig('plan_id'),
        service_id: app.dig('service_id')
      }
    end.compact
  rescue StandardError => e
    log "Error parsing applications from JSON: #{e.message}"
    []
  end

  def log(message)
    puts "    [DEBUG] #{message}" if verbose
  end

  def log_response(response)
    return unless verbose

    puts "    Response Code: #{response.code}"
    puts "    Response Body: #{response.body[0..500]}" # First 500 chars
  end

  def print_summary(duration)
    puts "\n"
    puts "=" * 80
    puts "SUMMARY"
    puts "=" * 80
    puts "Total iterations: #{iterations}"
    puts ""
    puts "Accounts created:        #{@stats[:created]}"
    puts "Accounts deleted:        #{@stats[:deleted]}"
    puts "Failed creates:          #{@stats[:failed_creates]}"
    puts "Failed deletes:          #{@stats[:failed_deletes]}"
    puts ""
    puts "Accounts with apps:      #{@stats[:with_applications]}"
    puts "Accounts without apps:   #{@stats[:no_applications]}"
    puts ""
    puts "Proxy calls successful:  #{@stats[:proxy_calls_success]}"
    puts "Proxy calls failed:      #{@stats[:proxy_calls_failed]}"
    puts ""
    puts "Duration:                #{duration.round(2)} seconds"
    puts "Average per iteration:   #{(duration / iterations).round(2)} seconds" if iterations > 0
    puts "=" * 80

    if @stats[:failed_creates] > 0 || @stats[:failed_deletes] > 0
      puts "\n⚠  WARNING: Some operations failed. Review the output above for details."
      exit 1
    else
      puts "\n✓ All operations completed successfully!"
      exit 0
    end
  end
end

# Main execution
if __FILE__ == $0
  base_url = ENV['THREESCALE_BASE_URL']
  access_token = ENV['THREESCALE_ACCESS_TOKEN']
  iterations = (ENV['CHURN_ITERATIONS'] || '10').to_i
  verbose = ENV['VERBOSE'] == 'true'

  unless base_url && access_token
    puts "ERROR: Missing required environment variables"
    puts ""
    puts "Required:"
    puts "  THREESCALE_BASE_URL      - Base URL of the 3scale instance"
    puts "  THREESCALE_ACCESS_TOKEN  - Access token for API authentication"
    puts ""
    puts "Optional:"
    puts "  CHURN_ITERATIONS         - Number of iterations (default: 10)"
    puts "  VERBOSE                  - Set to 'true' for detailed output (default: false)"
    puts ""
    puts "Example:"
    puts "  THREESCALE_BASE_URL=https://your-instance-admin.3scale.net \\"
    puts "  THREESCALE_ACCESS_TOKEN=your_token_here \\"
    puts "  CHURN_ITERATIONS=5 \\"
    puts "  ruby test_account_churn_api.rb"
    exit 1
  end

  test = ThreeScaleChurnTest.new(
    base_url: base_url,
    access_token: access_token,
    iterations: iterations,
    verbose: verbose
  )

  test.run
end
