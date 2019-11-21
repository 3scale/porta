# frozen_string_literal: true

require 'test_helper'

module Signup
  class PlansWithDefaultsTest < ActiveSupport::TestCase
    setup do
      @manager_account ||= FactoryBot.create(:provider_account)
      @service = @manager_account.first_service!
      @manager_account.update_attribute :default_account_plan, nil
      @service.update_attribute :default_service_plan, nil
      @service.update_attribute :default_application_plan, nil
    end

    context 'without default plans' do
      should 'be invalid on account plan without passed plans' do
        plans.selected = []

        assert plans.errors.any?
        assert_match /Account plan is required/i, plans.errors.to_sentence
        assert plans.to_a.empty?
      end

      should 'yield errors to proc' do
        errors = []
        plans = Signup::PlansWithDefaults.new(@manager_account, nil) { |error| errors << error }
        plans.selected = []

        assert plans.errors.any?
        assert_equal errors, plans.errors
      end
    end

    context 'with default account plan' do
      setup do
        @account_plan = FactoryBot.create(:account_plan, :issuer => @manager_account)
        @manager_account.update_attribute :default_account_plan, @account_plan
      end

      should 'select default account plan and nothing else' do
        plans.selected = []

        assert plans.errors.none?
        assert_equal [@account_plan], plans.to_a
      end

      context 'and default service plan' do
        setup do
          @service_plan = FactoryBot.create(:service_plan, :issuer => @service)
          @service.update_attribute :default_service_plan, @service_plan
        end

        should 'select default account and service plan' do
          plans.selected = []

          assert plans.errors.none?
          assert_equal [@account_plan, @service_plan], plans.to_a
        end

        should 'have error on service plan when tries to subscribe two plans' do
          service_plans = @service.service_plans
          plans.selected = service_plans

          assert plans.errors.any?
          assert_equal 1, plans.errors.size
          assert_match /subscribe only one plan per service/, plans.errors.to_sentence
        end

        context 'and default application plan' do
          setup do
            @application_plan = FactoryBot.create(:application_plan, :issuer => @service)
            @service.update_attribute :default_application_plan, @application_plan
          end

          should 'select default account, service and application plan' do
            plans.selected = []

            assert plans.errors.none?
            assert_equal [@account_plan, @service_plan, @application_plan], plans.to_a
          end
        end
      end

      context 'and default application plan without service plan' do
        setup do
          @application_plan = FactoryBot.create(:application_plan, :issuer => @service)
          @service.update_attribute :default_application_plan, @application_plan
        end

        should 'select only account plan' do
          plans.selected = []

          assert plans.errors.none?
          assert_equal [@account_plan], plans.to_a
        end

        should 'select all when passed service plan' do
          service_plan = @service.service_plans.first!
          plans.selected = [service_plan]

          assert plans.errors.none?
          assert_equal [@account_plan, service_plan, @application_plan], plans.to_a
        end


        should 'have error on application plan when explicitly selected' do
          plans.selected = [@application_plan]

          assert plans.errors.any?
          assert_equal 1, plans.errors.size
          assert_match /Couldn't find a Service Plan for/, plans.errors.to_sentence
        end

        should 'work when provider has service plans disabled and default plan' do
          service_plan = @service.service_plans.first!
          @manager_account.settings.service_plans_ui_visible = false

          plans.selected = []

          assert plans.errors.none?
          assert_equal [ @account_plan, service_plan , @application_plan], plans.to_a
        end

        should 'work when provider has service plans disabled' do
          service_plan = @service.service_plans.first!
          @manager_account.settings.service_plans_ui_visible = false

          plans.selected = [@application_plan]

          assert plans.errors.none?
          assert_equal [ @account_plan, service_plan , @application_plan], plans.to_a
        end

        should 'have error when rolling update is not active' do
          service_plan = @service.service_plans.first!
          service_plan.update_columns(state: 'published')
          @manager_account.settings.service_plans_ui_visible = false

          Logic::RollingUpdates.stubs(skipped?: true)

          plans.selected = [@application_plan]

          refute plans.errors.none?
          assert_equal [ @account_plan, @application_plan ], plans.to_a
          assert_match /Couldn't find a Service Plan/, plans.errors.to_sentence
        end

        should 'work without the rolling update' do
          service_plan = @service.service_plans.first!
          service_plan.update_columns(state: 'published')
          @manager_account.settings.service_plans_ui_visible = false

          Logic::RollingUpdates.stubs(skipped?: true)

          plans.selected = []

          assert plans.errors.none?
          assert_equal [ @account_plan], plans.to_a
        end

        should 'have error with hidden service plan when provider has service plans disabled' do
          service_plan = @service.service_plans.first!
          service_plan.update_columns(state: 'hidden') # default plans used to be hidden
          @manager_account.settings.service_plans_ui_visible = false

          plans.selected = [@application_plan]

          refute plans.errors.none?
          assert_equal [ @account_plan, @application_plan ], plans.to_a
          assert_match /Couldn't find a Service Plan/, plans.errors.to_sentence
        end
      end
    end

    private

    def plans
      @plans ||= Signup::PlansWithDefaults.new @manager_account
    end
  end
end
