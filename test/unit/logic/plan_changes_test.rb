require 'test_helper'

class Logic::PlanChangesTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    # TODO: use plain ruby objects and include the Logic::PlanChanges
    # into them
    @plan = FactoryBot.create(:application_plan, name: 'Old plan')
    @new_plan = FactoryBot.create(:application_plan, issuer: @plan.issuer, name: 'Better plan')
    @new_paid_plan = FactoryBot.create(:application_plan, issuer: @plan.issuer, name: 'New Better plan', :cost_per_month => 3)
    @new_plan.publish!

    @app = FactoryBot.create(:cinstance, plan: @plan)
    ActionMailer::Base.deliveries = []
  end

  class PlanChangePermission < Logic::PlanChangesTest
    test '#plan_change_permission_warning - direct' do
      @plan.issuer.stubs(plan_change_permission: :direct)
      assert_equal 'Are you sure you want to change your plan?',
                   @app.plan_change_permission_warning
    end

    test '#plan_change_permission_warning - request' do
      @plan.issuer.stubs(plan_change_permission: :request)
      assert_equal 'Are you sure you want to request a plan change?',
                   @app.plan_change_permission_warning
    end

    test '#plan_change_permission_warning - credit card missing' do
      @plan.issuer.stubs(plan_change_permission: :credit_card)
      @app.user_account.stubs(:credit_card_stored? => false)
      assert_equal 'Are you sure you want to request a plan change?',
                   @app.plan_change_permission_warning
    end

    test '#plan_change_permission_warning - credit card present' do
      @plan.issuer.stubs(plan_change_permission: :credit_card)
      @app.user_account.stubs(:credit_card_stored? => true)
      assert_equal 'Are you sure you want to change your plan?',
                   @app.plan_change_permission_warning
    end
  end

  class BuyerCahngesPlan < Logic::PlanChangesTest
    disable_transactional_fixtures!
    self.database_cleaner_strategy = :deletion
    self.database_cleaner_clean_with_strategy = :deletion

    setup do
      @provider = @plan.provider_account
      @buyer = @app.buyer_account
      @user = @buyer.first_admin
      User.stubs(:current).returns(@user)

      @provider.first_admin.notification_preferences.update(enabled_notifications: %i[cinstance_plan_changed application_plan_change_requested])
    end

    test '#buyer_changes_plan! - :direct' do
      @plan.issuer.stubs(plan_change_permission: :direct)
      @app.buyer_changes_plan!(@new_plan)
      assert_equal 'Better plan', @app.plan.name
    end

    test '#buyer_changes_plan! - :request' do
      @plan.issuer.stubs(plan_change_permission: :request)
      with_sidekiq do
        perform_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
          @app.buyer_changes_plan!(@new_plan)
        end
      end

      assert_equal 'Old plan', @app.plan.name
      assert_email_requests_exist
    end

    test '#buyer_changes_plan! - :credit_card (missing)' do
      @plan.issuer.stubs(plan_change_permission: :credit_card)
      @app.user_account.stubs(:credit_card_stored? => false)

      with_sidekiq do
        perform_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
          @app.buyer_changes_plan!(@new_plan)
        end
      end

      assert_equal 'Old plan', @app.plan.name
      assert_email_requests_exist
    end

    test '#buyer_changes_plan! - :credit_card (present)' do
      @plan.issuer.stubs(plan_change_permission: :credit_card)
      @app.user_account.stubs(:credit_card_stored? => true)

      with_sidekiq do
        perform_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
          @app.buyer_changes_plan!(@new_plan)
        end
      end

      assert_equal 'Better plan', @app.plan.name
      mail = ActionMailer::Base.deliveries.first
      assert_equal "Application #{@app.name} has changed to plan #{@new_plan.name}", mail.subject
    end

    test '#buyer_changes_plan! - :request_credit_card (present)' do
      @plan.issuer.stubs(plan_change_permission: :request_credit_card)
      @app.user_account.stubs(:credit_card_stored? => true)

      with_sidekiq do
        perform_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
          @app.buyer_changes_plan!(@new_plan)
        end
      end

      assert_equal 'Better plan', @app.plan.name
      mail = ActionMailer::Base.deliveries.first
      assert_equal "Application #{@app.name} has changed to plan #{@new_plan.name}", mail.subject
    end

    test '#buyer_changes_plan! - :request_credit_card (missing) - plan.paid' do
      @plan.issuer.stubs(plan_change_permission: :request_credit_card)
      @app.user_account.stubs(:credit_card_stored? => false)

      perform_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
        msg = @app.buyer_changes_plan!(@new_paid_plan)

        assert_equal "Please enter your credit card before changing the plan.", msg
        assert_equal 'Old plan', @app.plan.name
        assert_empty ActionMailer::Base.deliveries
      end
    end

    test '#buyer_changes_plan! - :request_credit_card (missing) - plan.free' do
      @plan.issuer.stubs(plan_change_permission: :request_credit_card)
      @app.user_account.stubs(:credit_card_stored? => false)

      with_sidekiq do
        perform_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
          msg = @app.buyer_changes_plan!(@new_plan)

          assert_equal "Plan change was successful.", msg
        end
      end

      assert_equal 'Better plan', @app.plan.name
      mail = ActionMailer::Base.deliveries.first
      assert_equal "Application #{@app.name} has changed to plan #{@new_plan.name}", mail.subject
    end
  end

  class PlanChangeActions < Logic::PlanChangesTest
    def test_request_plan_change_actions
      @plan.issuer.stubs(plan_change_permission: :request)

      Accounts::AccountPlanChangeRequestedEvent.expects(:create)

      assert @app.buyer_changes_plan!(FactoryBot.create(:account_plan))
    end

    def test_request_application_plan_change_action
      @plan.issuer.stubs(plan_change_permission: :request)

      Applications::ApplicationPlanChangeRequestedEvent.expects(:create)

      assert @app.buyer_changes_plan!(FactoryBot.create(:application_plan))
    end

    def test_request_service_plan_change_actions
      @plan.issuer.stubs(plan_change_permission: :request)

      Services::ServicePlanChangeRequestedEvent.expects(:create)

      assert @app.buyer_changes_plan!(FactoryBot.create(:service_plan))
    end
  end

  private

  def assert_email_requests_exist
    user = @user.decorate
    assert_equal ["Action required: #{user.informal_name} from #{@buyer.name} requested an app plan change", "Plan change request has been received"],
                 ActionMailer::Base.deliveries.map(&:subject)
  end
end
