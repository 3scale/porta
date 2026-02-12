require 'test_helper'

class User::StatesTest < ActiveSupport::TestCase

  test 'notify_activation for first_admin' do
    account = FactoryBot.create(:simple_provider)

    user1 = FactoryBot.create(:admin, account: account)
    ThreeScale::Analytics.expects(:track).with(user1, instance_of(String)).once
    user1.activate!

    user2 = FactoryBot.create(:admin, account: account)
    user2.activate!
  end

  test 'initializes activation_code upon creation' do
    user = FactoryBot.create(:simple_user)
    assert_not_nil user.activation_code
  end

  test 'user is created in pending state' do
    user = User.new(:username => 'foobar',
                    :email    => 'foobar@example.com')
    user.signup_type = :minimal
    user.save!

    assert user.pending?
  end

  test 'activate! transitions from pending to active' do
    user = FactoryBot.create(:simple_user)

    assert_change :of => user.method(:state), :from => "pending", :to => "active" do
      user.activate!
    end
  end

  test 'suspend! transitions from active to suspended' do
    user = FactoryBot.create(:simple_user)
    user.activate!

    assert_change :of => user.method(:state), :from => "active", :to => "suspended" do
      user.suspend!
    end
  end

  test  'suspend! transitions from suspended to suspended' do
    user = FactoryBot.create(:simple_user)

    user.activate!
    user.suspend!

    assert_no_change of: user.method(:state) do
      user.suspend!
    end
  end

  test 'unsuspend! transitions from suspended to active' do
    user = FactoryBot.create(:simple_user)
    user.activate!
    user.suspend!

    assert_change :of => user.method(:state), :from => "suspended", :to => "active" do
      user.unsuspend!
    end
  end

  test 'when user is activated, and his buyer account is created, it becomes pending' do
    account = FactoryBot.create(:buyer_account)

    account.update_attribute(:state, 'created')
    account.buy! FactoryBot.create(:account_plan, :approval_required => true)
    account.reload

    user    = FactoryBot.create(:pending_user, :account => account)

    # FIXME: [multiservice] account is missing bought_account_contract so cannot verify plan.approval_required?
    assert account.approval_required?
    assert_change :of => account.method(:state), :from => "created", :to => "pending" do
      user.activate!
    end
  end

  test 'when user is activated, and his account is approved, it will stay approved' do
    account = FactoryBot.create(:account_without_users)
    account.approve!

    user = FactoryBot.create(:pending_user, :account => account)

    assert_no_change :of => account.method(:state) do
      user.activate!
    end
  end

  class ActivateOnMinimalOrSampleDataTest < ActiveSupport::TestCase
    def setup
      @provider = FactoryBot.create(:simple_provider)
      @buyer = FactoryBot.create(:simple_buyer, provider_account: @provider)
      @user = FactoryBot.create(:pending_user, account: @buyer, password: 'superSecret1234#', password_confirmation: 'superSecret1234#')
    end

    test 'returns true for minimal signup with password and no approval required' do
      @user.signup_type = :minimal

      assert @user.activate_on_minimal_or_sample_data?
    end

    test 'returns true for sample_data signup with password and no approval required' do
      @user.signup_type = :sample_data

      assert @user.activate_on_minimal_or_sample_data?
    end

    test 'returns false for sample_data signup without password' do
      @user.signup_type = :sample_data
      @user.password = nil

      assert_not @user.activate_on_minimal_or_sample_data?
    end

    test 'returns false for sample_data signup when approval required' do
      @user.signup_type = :sample_data
      account_plan = FactoryBot.create(:account_plan, issuer: @provider, approval_required: true)
      @buyer.buy!(account_plan)

      assert_not @user.activate_on_minimal_or_sample_data?
    end

    test 'returns false for new_signup even with password' do
      @user.signup_type = :new_signup

      assert_not @user.activate_on_minimal_or_sample_data?
    end
  end
end

