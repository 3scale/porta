# frozen_string_literal: true

module Logic
  module ProviderSignup
    module Master
      def signup_provider_possible?
        ensure_master
        !!(services.default && account_plans.default && services.default.service_plans.default)
      end
    end

    class SampleData
      delegate :account_plans, :provided_plans, :default_service,
               :buyers, :api_docs_services, to: :@provider
      delegate :service_plans, :application_plans, to: :default_service

      alias service default_service

      def initialize(provider)
        @provider = provider
      end

      def create_default_account_plan!
        account_plans.default || account_plans.default!(account_plans.create!(name: 'Default'))
      end

      def create_default_service_plan!
        plan = service_plans.find_by(name: 'Default') || service_plans.create!(name: 'Default')
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
                            last_name: 'Doe', password: '123456', password_confirmation: '123456', signup_type: :sample_data}
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
        plan = application_plans.find_by(name: name) || application_plans.create!(name: name)
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
        default_service.api_docs_services.where(name: 'Echo').first_or_create!(body: simple_api_oas, published: true)
      end

      protected

      def simple_api_oas
        File.read(Rails.root.join('public', 'echo-api-3.0.json'))
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
