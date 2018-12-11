# frozen_string_literal: true

require_dependency 'simple_layout'
require_dependency 'three_scale/analytics'

module Logic
  module ProviderSignup
    module Master
      def signup_provider_possible?
        ensure_master
        !!(services.default && account_plans.default && services.default.service_plans.default)
      end

      def third_party_notifications!(provider, options = {})
        user = provider.first_admin

        properties = options.fetch(:analytics, {})

        user_tracking = ThreeScale::Analytics.user_tracking(user)
        user_tracking.identify(properties)
        user_tracking.track('Signup', properties)

      rescue => exception
        System::ErrorReporting.report_error(exception,
                        error_message: "Error adding signup to third parties",
                        error_class: 'ProviderSignup')
      end
    end

    class SampleData
      delegate :account_plans, :provided_plans, :default_service,
               :buyers, :api_docs_services, to: :@provider
      delegate :service_plans, :application_plans, to: :default_service

      ECHO_SERVICE = <<-EOBODY.freeze
  {
      "swagger": "2.0",
      "info": {
          "version": "1.0.0",
          "title": "Echo API",
          "description": "A sample echo API"
      },
      "host": "echo-api.3scale.net",
      "basePath": "/",
      "schemes": [
          "http"
      ],
      "consumes": [
          "application/json"
      ],
      "produces": [
          "application/json"
      ],
      "paths": {
          "/": {
              "get": {
                  "description": "Echo API with no parameters",
                  "operationId": "echo_no_params",
                  "produces": [
                      "application/json",
                      "application/xml",
                      "text/xml",
                      "text/html"
                  ],
                  "parameters": [
                      {
                          "name": "user_key",
                          "in": "query",
                          "description": "Your API access key",
                          "required": true,
                          "x-data-threescale-name": "user_keys",
                          "type": "string"
                      }
                  ],
                  "responses": {
                      "200": {
                          "description": "response",
                          "schema": {
                              "$ref": "#/definitions/ResponseModel"
                          }
                      },
                      "default": {
                          "description": "unexpected error",
                          "schema": {
                              "$ref": "#/definitions/ErrorModel"
                          }
                      }
                  }
              }
          },
          "/{echo}": {
              "get": {
                  "description": "Echo API with parameters",
                  "operationId": "echo_with_params",
                  "produces": [
                      "application/json",
                      "application/xml",
                      "text/xml",
                      "text/html"
                  ],
                  "parameters": [
                      {
                          "name": "echo",
                          "in": "path",
                          "description": "The string to be echoed",
                          "required": true,
                          "type": "string"
                      },
                      {
                          "name": "user_key",
                          "in": "query",
                          "description": "Your API access key",
                          "required": true,
                          "x-data-threescale-name": "user_keys",
                          "type": "string"
                      }
                  ],
                  "responses": {
                      "200": {
                          "description": "response",
                          "schema": {
                              "$ref": "#/definitions/ResponseModel"
                          }
                      },
                      "default": {
                          "description": "unexpected error",
                          "schema": {
                              "$ref": "#/definitions/ErrorModel"
                          }
                      }
                  }
              }
          }
      },
      "definitions": {
          "ResponseModel": {
              "type": "object",
              "required": [
                  "method",
                  "path",
                  "args",
                  "headers"
              ],
              "properties": {
                  "method": {
                      "type": "string"
                  },
                  "path": {
                      "type": "string"
                  },
                  "args": {
                      "type": "string"
                  },
                  "headers": {
                      "type": "object"
                  }
              }
          },
          "ErrorModel": {
              "type": "object",
              "required": [
                  "code",
                  "message"
              ],
              "properties": {
                  "code": {
                      "type": "integer",
                      "format": "int32"
                  },
                  "message": {
                      "type": "string"
                  }
              }
          }
      }
  }
      EOBODY

      alias service default_service

      def initialize(provider)
        @provider = provider
      end

      def create_default_account_plan!
        account_plans.default || account_plans.default!(account_plans.create!(name: 'Default'))
      end

      def create_default_service_plan!
        plan = service_plans.find_by_name('Default') || service_plans.create!(name: 'Default')
        service.service_plans.default! plan
      end

      def create!
        original_updated_at = service.updated_at

        create_default_account_plan!
        create_default_service_plan!

        basic_plan = create_application_plan!('Basic', features: basic_features)
        unlimited_plan = create_application_plan!('Unlimited', features: basic_features + unlimited_features)

        application_plans.default!(basic_plan)

        publish(basic_plan)

        ensure_users(1)

        publish(unlimited_plan)

        create_active_docs_service!

        service.update_column(:updated_at, original_updated_at)
      end

      def email
        @provider.admins.first.email
      end

      def ensure_users(count)
        (count - buyers.size).times do
          signup_user
        end
      end

      def signup_user
        email_part = email.split('@')
        user_attributes = { email: "#{email_part[0]}+test@#{email_part[1]}", username: 'john', first_name: 'John',
                            last_name: 'Doe', password: '123456', password_confirmation: '123456', signup_type: :minimal}
        signup_params = ::Signup::SignupParams.new(plans: [], user_attributes: user_attributes, account_attributes: { org_name: 'Developer' })
        ::Signup::DeveloperAccountManager.new(@provider).create(signup_params)
      end

      def basic_features
        [
          application_plan_feature('Unlimited Greetings')
        ]
      end

      def unlimited_features
        [
          application_plan_feature('24/7 support'),
          application_plan_feature('Unlimited calls')
        ]
      end

      def create_application_plan!(name, features: [])
        plan = application_plans.find_by_name(name) || application_plans.create!(name: name)
        features.each {|feature| plan.features << feature unless plan.features.include?(feature) }
        plan
      end

      def application_plan_feature(name)
        scope = 'ApplicationPlan'
        attributes = { name: name, scope: scope }
        features = service.features
        features.where(attributes).first || features.create!(attributes)
      end

      def publish(plan)
        plan.publish! unless plan.published?
      end

      def create_active_docs_service!
        default_service.api_docs_services.where(name: 'Echo').first_or_create!(body: ECHO_SERVICE, published: true)
      end
    end

    module Provider
      def classify
        extra_fields['account_type'] = ::ThreeScale::Analytics::AccountClassifier.classify(self)
      end

      def signup_mode!
        @signup_mode = true
      end

      def signup?
        !!@signup_mode
      end

      def import_simple_layout!
        SimpleLayout.new(self).import!
      end

      def create_sample_data!
        Rails.logger.debug "Creating sample data for provider #{id}"

        sample_data = SampleData.new(self)

        ActiveRecord::Base.transaction do
          return unless sample_data? # it was already created

          sample_data.create!

          update_column(:sample_data, false)

          Rails.logger.debug "Done creating sample data for provider #{id}"
        end
      ensure
        Rails.logger.debug "Finished sample data for provider #{id}"
      end
    end
  end
end
