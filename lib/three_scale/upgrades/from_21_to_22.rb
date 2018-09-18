# frozen_string_literal: true

# This upgrade class performs requirement tasks for upgrading from AMP 2.1 to AMP 2.2
#   1. creates master admin user
#   2. creates master account's default metrics
#   3. creates master user's access token
#   4. creates APIcast's access token
#   5. allows master settings switches
#   6. updates master's default service with some notification settings and a default application plan
#
# Make sure the following environment variables are available when executing
#   - MASTER_USER: master user's username to log in to Admin portal (default: master)
#   - MASTER_PASSWORD: master user's password to log in to Admin portal (generated randomly if omitted)
#   - MASTER_ACCESS_TOKEN: required to perform account management actions from the Master API (required)
#   - APICAST_ACCESS_TOKEN: must coincide with the access token present in APIcast's THREESCALE_PORTAL_ENDPOINT env var (required)
module ThreeScale
  module Upgrades
    class From21To22
      def self.run
        if should_run?
          new.run
        else
          Rails.logger.info 'Nothing to do.'
        end
      end

      def self.should_run?
        ThreeScale.config.onpremises && !Account.master.admin_users.exists? && System::Database.mysql?
      end

      delegate :info, to: 'Rails.logger'
      delegate :master, to: 'Account'

      def run
        info 'Starting requirements update...'

        create_master_admin_user
        create_master_default_metrics
        create_master_access_token
        create_apicast_access_token
        allow_master_settings
        update_master_service

        info 'Requirements update finished.'
      end

      # Creates master admin user
      def create_master_admin_user
        info 'Creating master admin user...'

        if master.admin_users.any?
          info 'Master admin user already exists'
          return
        end

        master_login = ENV.fetch('MASTER_USER', 'master')
        master_password = ENV.fetch('MASTER_PASSWORD') { SecureRandom.base64(32) }

        User.create!(username: master_login, password: master_password, password_confirmation: master_password) do |user|
          user.signup_type = 'minimal'
          user.account = master
          user.role = :admin
          user.activate!
        end

        info "New master admin user created with login #{master_login} and password #{master_password}"
      end
      
      DELTA_METRICS = { billing: 'Billing API', account: 'Account Management API', analytics: 'Analytics API' }.freeze

      # Creates master default metrics
      def create_master_default_metrics
        info 'Creating master default metrics...'

        master_service = master.default_service
        current_master_metrics = master_service.metrics.pluck(:system_name)
        master_delta_metrics = DELTA_METRICS.slice(current_master_metrics)

        master_delta_metrics.each do |system_name, description|
          master_service.metrics.create!(system_name: system_name, unit: 'hit', friendly_name: description)
        end

        info "Master default metrics: #{current_master_metrics | master_delta_metrics.values}"
      end

      # Creates master access token
      def create_master_access_token
        info 'Creating master access token...'

        master_user = master.admin_users.first!
        master_access_token = master_user.access_tokens.create!(name: 'Master Token', scopes: %w[account_management], permission: 'rw') do |token|
          if (value = ENV['MASTER_ACCESS_TOKEN'])
            token.value = value
          end
        end.value
        info "Master RW access token: #{master_access_token}"
      end

      # Creates apicast access token
      def create_apicast_access_token
        info 'Creating APIcast access token...'

        master_user = master.admin_users.first!
        apicast_access_token = master_user.access_tokens.create!(name: 'APIcast', scopes: %w[account_management], permission: 'ro') do |token|
          if (value = ENV['APICAST_ACCESS_TOKEN'].presence)
            token.value = value
          end
        end.value
        info "APIcast access token: #{apicast_access_token}"
      end

      # Allows master settings switches
      def allow_master_settings
        info 'Allowing master settings switches...'

        master.settings.allow_branding!

        info 'Allowing Master settings switches finished.'
      end

      # Updates master default service
      def update_master_service
        info 'Updating master default service...'

        master_service = master.default_service
        range = [0] | Alert::ALERT_LEVELS
        master_service.notification_settings = { web_buyer: range, email_buyer: range, web_provider: range, email_provider: range}
        master_service.save!

        application_plan = ApplicationPlan.find_by!(issuer: master_service, name: 'Master Plan')
        master_service.update_attribute(:default_application_plan, application_plan)

        info 'Master default services updated.'
      end
    end
  end
end
