require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class User::StatesTest < ActiveSupport::TestCase

  test 'notify_activation for first_admin' do
    account = Factory(:simple_provider)

    user1 = Factory(:admin, account: account)
    user1.activate!

    user2 = Factory(:admin, account: account)
    user2.activate!

    ThreeScale::Analytics.expects(:track).with(user1, instance_of(String)).once

    user1.send(:_run_after_commit_queue)
    user2.send(:_run_after_commit_queue)
  end

  test 'initializes activation_code upon creation' do
    user = Factory(:simple_user)
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
    user = Factory(:simple_user)

    assert_change :of => user.method(:state), :from => "pending", :to => "active" do
      user.activate!
    end
  end

  test 'suspend! transitions from active to suspended' do
    user = Factory(:simple_user)
    user.activate!

    assert_change :of => user.method(:state), :from => "active", :to => "suspended" do
      user.suspend!
    end
  end

  test  'suspend! transitions from suspended to suspended' do
    user = Factory(:simple_user)

    user.activate!
    user.suspend!

    assert_no_change of: user.method(:state) do
      user.suspend!
    end
  end

  test 'unsuspend! transitions from suspended to active' do
    user = Factory(:simple_user)
    user.activate!
    user.suspend!

    assert_change :of => user.method(:state), :from => "suspended", :to => "active" do
      user.unsuspend!
    end
  end

  test 'when user is activated, and his buyer account is created, it becomes pending' do
    account = Factory(:buyer_account_with_provider)

    account.update_attribute(:state, 'created')
    account.buy! Factory(:account_plan, :approval_required => true)
    account.reload

    user    = Factory(:pending_user, :account => account)

    # FIXME: [multiservice] account is missing bought_account_contract so cannot verify plan.approval_required?
    assert account.approval_required?
    assert_change :of => account.method(:state), :from => "created", :to => "pending" do
      user.activate!
    end
  end

  test 'when user is activated, and his account is approved, it will stay approved' do
    account = Factory(:account_without_users)
    account.approve!

    user = Factory(:pending_user, :account => account)

    assert_no_change :of => account.method(:state) do
      user.activate!
    end
  end
end

