#!/usr/bin/env ruby
# frozen_string_literal: true

# Test script for creating 3scale Backend, Service, BackendUsage, and promoting to staging
#
# Usage:
#   ruby test_service_setup_api.rb
#
# Environment variables:
#   THREESCALE_BASE_URL - Base URL of the 3scale instance (e.g., https://your-instance-admin.3scale.net)
#   THREESCALE_ACCESS_TOKEN - Access token for API authentication
#   CHURN_ITERATIONS - Number of times to repeat the create cycle (default: 10)
#   VERBOSE - Set to 'true' for detailed output (default: false)

require 'net/http'
require 'uri'
require 'json'
require 'openssl'

class ThreeScaleServiceSetup
  attr_reader :base_url, :access_token, :iterations, :verbose

  def initialize(base_url:, access_token:, iterations: 10, verbose: false)
    @base_url = base_url.chomp('/')
    @access_token = access_token
    @iterations = iterations
    @verbose = verbose
    @stats = {
      backends_created: 0,
      services_created: 0,
      backend_usages_created: 0,
      proxies_updated: 0,
      promotions_successful: 0,
      verifications_successful: 0,
      services_deleted: 0,
      backends_deleted: 0,
      failed_operations: 0
    }
  end

  def run
    puts "Starting 3scale Service Setup Test"
    puts "Base URL: #{base_url}"
    puts "Iterations: #{iterations}"
    puts "=" * 80

    start_time = Time.now

    iterations.times do |i|
      iteration_num = i + 1
      puts "\n[#{iteration_num}/#{iterations}] Starting iteration..."

      run_iteration(iteration_num)
    end

    end_time = Time.now
    duration = end_time - start_time

    print_summary(duration)
  end

  private

  def run_iteration(iteration_num)
    backend_id = nil
    service_id = nil

    # Step 1: Create Backend
    backend_id = create_backend(iteration_num)
    return unless backend_id

    # Step 2: Create Service
    service_id = create_service(iteration_num)
    return unless service_id

    # Step 3: Create BackendUsage
    unless create_backend_usage(service_id, backend_id)
      return
    end

    # Step 4: Update Proxy
    unless update_proxy(service_id)
      return
    end

    # Step 5: Deploy to Staging (deploys latest version automatically)
    unless deploy_proxy(service_id)
      return
    end

    # Step 6: Verify deployed version is 2
    unless verify_deployed_version(service_id, expected_version: 2)
      return
    end

    # Step 7: Verify Configuration
    unless verify_proxy_configuration(service_id)
      return
    end

    # Step 7: Delete Service (this will also delete BackendUsage)
    delete_service(service_id)

    # Step 8: Delete Backend
    delete_backend(backend_id)
  end

  def create_backend(iteration)
    timestamp = Time.now.to_i
    random_suffix = rand(36**4).to_s(36).rjust(4, '0')
    backend_name = "TestBackend#{iteration}_#{timestamp}_#{random_suffix}"
    private_endpoint = "https://echo-api.3scale.net"

    log "Creating Backend: #{backend_name}"

    uri = URI("#{base_url}/admin/api/backend_apis.json")
    uri.query = URI.encode_www_form('access_token' => access_token)

    params = {
      'name' => backend_name,
      'private_endpoint' => private_endpoint,
      'system_name' => "backend_#{iteration}_#{timestamp}_#{random_suffix}"
    }

    response = make_request(uri, :post, params)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      backend_id = data.dig('backend_api', 'id')

      if backend_id
        @stats[:backends_created] += 1
        puts "  ✓ Backend created successfully (ID: #{backend_id})"
        backend_id
      else
        @stats[:failed_operations] += 1
        puts "  ✗ Failed to extract backend ID from response"
        log_response(response)
        nil
      end
    else
      @stats[:failed_operations] += 1
      puts "  ✗ Backend creation failed (HTTP #{response.code})"
      log_response(response)
      nil
    end
  rescue StandardError => e
    @stats[:failed_operations] += 1
    puts "  ✗ Exception during backend creation: #{e.message}"
    log e.backtrace.join("\n") if verbose
    nil
  end

  def create_service(iteration)
    timestamp = Time.now.to_i
    random_suffix = rand(36**4).to_s(36).rjust(4, '0')
    service_name = "TestService#{iteration}_#{timestamp}_#{random_suffix}"

    log "Creating Service: #{service_name}"

    uri = URI("#{base_url}/admin/api/services.json")
    uri.query = URI.encode_www_form('access_token' => access_token)

    params = {
      'name' => service_name,
      'system_name' => "service_#{iteration}_#{timestamp}_#{random_suffix}"
    }

    response = make_request(uri, :post, params)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      service_id = data.dig('service', 'id')

      if service_id
        @stats[:services_created] += 1
        puts "  ✓ Service created successfully (ID: #{service_id})"
        service_id
      else
        @stats[:failed_operations] += 1
        puts "  ✗ Failed to extract service ID from response"
        log_response(response)
        nil
      end
    else
      @stats[:failed_operations] += 1
      puts "  ✗ Service creation failed (HTTP #{response.code})"
      log_response(response)
      nil
    end
  rescue StandardError => e
    @stats[:failed_operations] += 1
    puts "  ✗ Exception during service creation: #{e.message}"
    log e.backtrace.join("\n") if verbose
    nil
  end

  def create_backend_usage(service_id, backend_id)
    log "Creating BackendUsage for Service #{service_id} and Backend #{backend_id}"

    uri = URI("#{base_url}/admin/api/services/#{service_id}/backend_usages.json")
    uri.query = URI.encode_www_form('access_token' => access_token)

    params = {
      'backend_api_id' => backend_id,
      'path' => '/'
    }

    response = make_request(uri, :post, params)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      usage_id = data.dig('backend_usage', 'id')

      if usage_id
        @stats[:backend_usages_created] += 1
        puts "  ✓ BackendUsage created successfully (ID: #{usage_id})"
        true
      else
        @stats[:failed_operations] += 1
        puts "  ✗ Failed to extract backend usage ID from response"
        log_response(response)
        false
      end
    else
      @stats[:failed_operations] += 1
      puts "  ✗ BackendUsage creation failed (HTTP #{response.code})"
      log_response(response)
      false
    end
  rescue StandardError => e
    @stats[:failed_operations] += 1
    puts "  ✗ Exception during backend usage creation: #{e.message}"
    log e.backtrace.join("\n") if verbose
    false
  end

  def update_proxy(service_id)
    log "Updating Proxy for Service #{service_id}"

    uri = URI("#{base_url}/admin/api/services/#{service_id}/proxy.json")
    uri.query = URI.encode_www_form('access_token' => access_token)

    # Add a unique timestamp to the secret_token to ensure a new version is created
    timestamp = Time.now.to_i

    params = {
      'credentials_location' => 'query',
      'auth_user_key' => 'user_key',
      'error_status_auth_failed' => 403,
      'error_headers_auth_failed' => 'text/plain; charset=us-ascii',
      'error_auth_failed' => 'Authentication failed',
      'error_status_auth_missing' => 403,
      'error_headers_auth_missing' => 'text/plain; charset=us-ascii',
      'error_auth_missing' => 'Authentication parameters missing',
      'api_test_path' => '/',
      'secret_token' => "test_secret_#{timestamp}"
    }

    response = make_request(uri, :patch, params)

    if response.is_a?(Net::HTTPSuccess)
      @stats[:proxies_updated] += 1
      puts "  ✓ Proxy updated successfully"
      true
    else
      @stats[:failed_operations] += 1
      puts "  ✗ Proxy update failed (HTTP #{response.code})"
      log_response(response)
      false
    end
  rescue StandardError => e
    @stats[:failed_operations] += 1
    puts "  ✗ Exception during proxy update: #{e.message}"
    log e.backtrace.join("\n") if verbose
    false
  end

  def deploy_proxy(service_id)
    log "Deploying Proxy to Staging for Service #{service_id}"

    # POST /admin/api/services/{service_id}/proxy/deploy.json
    # This automatically deploys the latest proxy config to staging
    uri = URI("#{base_url}/admin/api/services/#{service_id}/proxy/deploy.json")
    uri.query = URI.encode_www_form('access_token' => access_token)

    response = make_request(uri, :post)

    if response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPCreated)
      @stats[:promotions_successful] += 1
      puts "  ✓ Deployed to staging successfully"
      true
    else
      @stats[:failed_operations] += 1
      puts "  ✗ Deployment to staging failed (HTTP #{response.code})"
      log_response(response)
      false
    end
  rescue StandardError => e
    @stats[:failed_operations] += 1
    puts "  ✗ Exception during deployment: #{e.message}"
    log e.backtrace.join("\n") if verbose
    false
  end

  def verify_deployed_version(service_id, expected_version:)
    log "Verifying deployed version for Service #{service_id}"

    # GET /admin/api/services/{service_id}/proxy/configs/sandbox/latest.json
    uri = URI("#{base_url}/admin/api/services/#{service_id}/proxy/configs/sandbox/latest.json")
    uri.query = URI.encode_www_form('access_token' => access_token)

    response = make_request(uri, :get)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      deployed_version = data.dig('proxy_config', 'version')

      if deployed_version == expected_version
        puts "  ✓ Deployed version is #{deployed_version} (expected: #{expected_version})"
        true
      else
        @stats[:failed_operations] += 1
        puts "  ✗ Deployed version is #{deployed_version}, expected #{expected_version}"
        log_response(response)
        false
      end
    else
      @stats[:failed_operations] += 1
      puts "  ✗ Failed to retrieve deployed version (HTTP #{response.code})"
      log_response(response)
      false
    end
  rescue StandardError => e
    @stats[:failed_operations] += 1
    puts "  ✗ Exception during version verification: #{e.message}"
    log e.backtrace.join("\n") if verbose
    false
  end

  def verify_proxy_configuration(service_id)
    log "Verifying Proxy Configuration for Service #{service_id}"

    uri = URI("#{base_url}/admin/api/services/#{service_id}/proxy.json")
    uri.query = URI.encode_www_form('access_token' => access_token)

    response = make_request(uri, :get)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      proxy = data['proxy']

      if proxy
        @stats[:verifications_successful] += 1
        puts "  ✓ Proxy configuration verified successfully"

        if verbose
          puts "    Service ID:           #{proxy['service_id']}"
          puts "    Endpoint:             #{proxy['endpoint']}"
          puts "    Sandbox Endpoint:     #{proxy['sandbox_endpoint']}"
          puts "    Credentials Location: #{proxy['credentials_location']}"
          puts "    Auth User Key:        #{proxy['auth_user_key']}"
          puts "    API Test Path:        #{proxy['api_test_path']}"
          puts "    Version:              #{proxy['version']}"
        end

        true
      else
        @stats[:failed_operations] += 1
        puts "  ✗ Failed to extract proxy configuration from response"
        log_response(response)
        false
      end
    else
      @stats[:failed_operations] += 1
      puts "  ✗ Failed to retrieve proxy configuration (HTTP #{response.code})"
      log_response(response)
      false
    end
  rescue StandardError => e
    @stats[:failed_operations] += 1
    puts "  ✗ Exception during proxy configuration verification: #{e.message}"
    log e.backtrace.join("\n") if verbose
    false
  end

  def delete_service(service_id)
    log "Deleting Service #{service_id}"

    uri = URI("#{base_url}/admin/api/services/#{service_id}.json")
    uri.query = URI.encode_www_form('access_token' => access_token)

    response = make_request(uri, :delete)

    if response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPNoContent)
      @stats[:services_deleted] += 1
      puts "  ✓ Service deleted successfully"
    else
      @stats[:failed_operations] += 1
      puts "  ✗ Service deletion failed (HTTP #{response.code})"
      log_response(response)
    end
  rescue StandardError => e
    @stats[:failed_operations] += 1
    puts "  ✗ Exception during service deletion: #{e.message}"
    log e.backtrace.join("\n") if verbose
  end

  def delete_backend(backend_id)
    log "Deleting Backend #{backend_id}"

    uri = URI("#{base_url}/admin/api/backend_apis/#{backend_id}.json")
    uri.query = URI.encode_www_form('access_token' => access_token)

    response = make_request(uri, :delete)

    if response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPNoContent)
      @stats[:backends_deleted] += 1
      puts "  ✓ Backend deleted successfully"
    else
      @stats[:failed_operations] += 1
      puts "  ✗ Backend deletion failed (HTTP #{response.code})"
      log_response(response)
    end
  rescue StandardError => e
    @stats[:failed_operations] += 1
    puts "  ✗ Exception during backend deletion: #{e.message}"
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
                  req.set_form_data(params)
                end
                req
              when :patch
                req = Net::HTTP::Patch.new(uri)
                if params
                  req.set_form_data(params)
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

  def log(message)
    puts "    [DEBUG] #{message}" if verbose
  end

  def log_response(response)
    return unless verbose

    puts "    Response Code: #{response.code}"
    puts "    Response Body: #{response.body}" # First 500 chars
  end

  def print_summary(duration)
    puts "\n"
    puts "=" * 80
    puts "SUMMARY"
    puts "=" * 80
    puts "Total iterations:           #{iterations}"
    puts ""
    puts "Backends created:           #{@stats[:backends_created]}"
    puts "Services created:           #{@stats[:services_created]}"
    puts "Backend usages created:     #{@stats[:backend_usages_created]}"
    puts "Proxies updated:            #{@stats[:proxies_updated]}"
    puts "Promotions successful:      #{@stats[:promotions_successful]}"
    puts "Verifications successful:   #{@stats[:verifications_successful]}"
    puts ""
    puts "Services deleted:           #{@stats[:services_deleted]}"
    puts "Backends deleted:           #{@stats[:backends_deleted]}"
    puts ""
    puts "Failed operations:          #{@stats[:failed_operations]}"
    puts ""
    puts "Duration:                   #{duration.round(2)} seconds"
    puts "Average per iteration:      #{(duration / iterations).round(2)} seconds" if iterations > 0
    puts "=" * 80

    if @stats[:failed_operations] > 0
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
    puts "  ruby test_service_setup_api.rb"
    exit 1
  end

  setup = ThreeScaleServiceSetup.new(
    base_url: base_url,
    access_token: access_token,
    iterations: iterations,
    verbose: verbose
  )

  setup.run
end