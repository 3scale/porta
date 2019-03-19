require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class CinstanceObserverTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  fixtures :countries

  def setup
    @plan = FactoryBot.create(:application_plan)
    @service = @plan.service

    @buyer = FactoryBot.create(:buyer_account)

    @provider = @plan.provider_account

    Logic::RollingUpdates.stubs(skipped?: true)
  end

  context 'When new cinstance is created' do
    setup do
      @cinstance = @buyer.buy!(@plan)
    end

    context 'a message' do
      setup { @message = Message.last }

      should 'be sent' do
        assert_not_nil @message
        assert @message.sent?
      end

      should 'have the provider as a recipient' do
        assert_equal [@provider], @message.to
      end

      should 'have the buyer as a sender' do
        assert_equal @buyer, @message.sender
      end

      should 'have meaningful subject' do
        assert_match(/New Application submission/i, @message.subject)
      end

      should 'contain service name' do
        assert_match(@service.name, @message.body)
      end

      should 'contain plan name' do
        assert_match(@plan.name, @message.body)
      end

      should 'contain buyer name' do
        assert_match(@buyer.org_name, @message.body)
      end

      should 'contain buyer email' do
        assert_match(@buyer.admins.first.email, @message.body)
      end

      should_eventually 'contain link to cinstance' do

      end
    end
  end

  context 'When new cinstance of service that requires approval is created' do
    setup do
      @plan.update_attribute(:approval_required, true)
      @cinstance = @buyer.buy!(@plan)
    end

    context 'a message' do
      setup { @message = Message.last }

      should 'say that the cinstance needs approval' do
        assert_match(/requires you to approve/i, @message.body)
      end
    end
  end

  context 'When new cinstance of service that does not require approval is created' do
    setup do
      @plan.update_attribute(:approval_required, false)
      @cinstance = @buyer.buy!(@plan)
    end

    context 'a message' do
      setup { @message = Message.last }

      should 'not say that the cinstance needs approval' do
        refute_match(/requires your approval/i, @message.body)
      end
    end
  end

  test 'does not send accept message to buyer if plan does not require approval' do
    @plan.update_attribute(:approval_required, false)

    assert_no_difference '@buyer.received_messages.count' do
      @buyer.buy!(@plan)
    end
  end

  context 'When cinstance is cancelled' do
    setup do
      @cinstance = @buyer.buy!(@plan)
      Message.destroy_all

      @cinstance.destroy
    end

    context 'a message' do
      setup do
        assert @message = Message.last
      end

      should 'be sent' do
        assert_not_nil @message
        assert @message.sent?
      end

      should 'have the provider as a recipient' do
        assert_equal [@provider], @message.to
      end

      should 'have the buyer as a sender' do
        assert_equal @buyer, @message.sender
      end

      should 'have meaningful subject' do
        assert_not_nil @message.subject
      end

      should 'contain service name' do
        assert_match(@service.name, @message.body)
      end

      should 'contain plan name' do
        assert_match(@plan.name, @message.body)
      end

      should 'contain buyer name' do
        assert_match(@buyer.org_name, @message.body)
      end
    end
  end

  context 'When cinstance changes a plan' do
    setup do
      @cinstance = @buyer.buy!(@plan)
      @new_plan = FactoryBot.create( :application_plan, :issuer => @service)

      @cinstance.change_plan!(@new_plan)
      @cinstance.save!
    end

    context 'a message to provider' do
      setup { @message = @buyer.messages.last }

      should 'be sent' do
        assert_not_nil @message
        assert @message.sent?
      end

      should 'have the provider as a recipient' do
        assert_equal [@provider], @message.to
      end

      should 'contain service name' do
        assert_match(@service.name, @message.body)
      end

      should 'contain buyer name' do
        assert_match(@buyer.org_name, @message.body)
      end

      should 'contain old plan name'

      should 'contain new plan name' do
        assert_match(@new_plan.name, @message.body)
      end
    end

    context 'a message to buyer' do
      setup { @message = @provider.messages.last }

      should 'be sent' do
        assert_not_nil @message
        assert @message.sent?
      end

      should 'have the buyer as a recipient' do
        assert_equal [@buyer], @message.to
      end

      should 'contain new plan name' do
        assert_match(@new_plan.name, @message.body)
      end
    end
  end

  context 'When pending cinstance' do
    setup do
      @plan.update_attribute(:approval_required, true)
      @cinstance = @buyer.buy!(@plan)
    end

    context 'is accepted' do
      setup { @cinstance.accept! }

      context 'a message' do
        setup { @message = Message.last }

        should 'be sent' do
          assert_not_nil @message
          assert @message.sent?
        end

        should 'have the buyer as a recipient' do
          assert_equal [@buyer], @message.to
        end

        should 'have meaningful subject' do
          assert_not_nil @message.subject
        end

        should 'contain provider name' do
          assert_match(@provider.org_name, @message.body)
        end

        should 'contain service name' do
          assert_match(@cinstance.service.name, @message.body)
        end

        should 'contain plan name' do
          assert_match(@cinstance.plan.name, @message.body)
        end

        should 'contain link to cinstance details'
      end
    end

    context 'is rejected' do
      setup { @cinstance.reject!('any reason') }

      context 'a message' do
        setup { @message = Message.last }

        should 'be sent' do
          assert_not_nil @message
          assert @message.sent?
        end
      end
    end
  end
end
