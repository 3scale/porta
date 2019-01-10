require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class InvitationTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  should belong_to :account

  def setup
    @provider = FactoryBot.create(:simple_provider)
  end

  test 'requires an email' do
    invitation = Invitation.new(:account => @provider)

    refute invitation.valid?
    assert invitation.errors[:email].include? "can't be blank"
  end

  test 'requires the email to not belong to a provider user' do
    user = FactoryBot.create(:simple_user, :account => @provider)
    invitation = Invitation.new(:account => @provider, :email => user.email)

    refute invitation.valid?
    assert invitation.errors[:email].include? 'has been taken by another user'
  end

  test 'does not require the email to not belong to a buyer user' do
    buyer = FactoryBot.create :simple_buyer, :provider_account => @provider
    buyer_user = FactoryBot.create(:simple_user, :account => buyer)
    invitation = Invitation.new(:account => @provider, :email => buyer_user.email)

    assert invitation.valid?
  end

  test 'does not require globally unique email' do
    other_account = FactoryBot.create(:simple_account)
    other_user = FactoryBot.create(:simple_user, :account => other_account)
    invitation = @provider.invitations.new(:email => other_user.email)

    assert invitation.valid?
  end

  test 'generates unique token' do
    invitation = @provider.invitations.create!(:email => 'buddy@example.net')
    assert_not_nil invitation.token
  end

  test 'sends invitation email when created' do
    ProviderInvitationMailer.any_instance.expects(:invitation)
    @provider.invitations.create!(:email => 'buddy@example.net')
  end

  test 'sets sent_at field when created' do
    Timecop.freeze(Time.zone.now) do
      invitation = @provider.invitations.create!(:email => 'buddy@example.net')
      assert_equal Time.zone.now, invitation.sent_at
    end
  end

  test 'resend unaccepted invitation email' do
    @unaccepted_invitation = @provider.invitations.create!(:email => 'buddy@example.net')

    # REVIEW: ProviderInvitationMailer.any_instance.expects(:invitation)
    # Before mails in background only call one time
    ProviderInvitationMailer.any_instance.expects(:invitation)
    @unaccepted_invitation.resend
  end

  test '#resend unaccepted invitationset sent_at field' do
    @unaccepted_invitation = @provider.invitations.create!(:email => 'buddy@example.net')
    last_sent_at = @unaccepted_invitation.sent_at

    Timecop.travel(2.days.from_now) do
      @unaccepted_invitation.resend
      assert_not_equal last_sent_at, @unaccepted_invitation.sent_at
    end
  end

  test '#resend accepted should not send invitation email' do
    @accepted_invitation = @provider.invitations.create!(:email => 'buddy@example.net')
    @accepted_invitation.accept!
    last_sent_at = @accepted_invitation.sent_at
    InvitationMailer.expects(:deliver_invitation).never

    @accepted_invitation.resend

    assert_equal last_sent_at.to_s, @accepted_invitation.sent_at.to_s
  end

  test 'Invitation#make_user builds an user' do
    invitation = @provider.invitations.create!(:email => 'bob@example.net')
    user = invitation.make_user(:username => 'bobby')

    assert_not_nil user
    assert user.new_record?
    assert_equal @provider, user.account
    assert_equal 'bob@example.net', user.email
    assert_equal 'bobby', user.username
  end

  test 'Invitation#accept! accepts the invitation' do
    invitation = @provider.invitations.create!(:email => 'bob@example.com')

    Timecop.freeze(Time.utc(2010, 3, 12)) do
      assert_change :of => lambda { invitation.accepted? }, :from => false, :to => true do
        invitation.accept!
      end

      assert_equal Time.utc(2010, 3, 12), invitation.accepted_at
    end
  end

  test 'Invitation#accept! does nothing for already accepted invitation' do
    invitation = @provider.invitations.create!(:email => 'bob@example.com')
    invitation.accept!

    Timecop.travel(2.days.from_now) do
      assert_no_change :of => lambda { invitation.accepted_at } do
        invitation.accept!
      end
    end
  end

  test 'creating invited user accepts the invitation' do
    invitation = @provider.invitations.create!(:email => 'bob@example.net')
    user = invitation.make_user(:username => 'bob', :password => 'monkey')

    assert_change :of => lambda { invitation.accepted? }, :from => false, :to => true do
      user.save!
      invitation.reload
    end

    assert_equal invitation.user, user
  end

  # this test is pathethic because is testing Rails.
  test '#pending named scope' do
    @pending = @provider.invitations.create!(:email => 'bob@example.net')
    @accepted = @provider.invitations.create!(:email => 'tom@example.net')
    @accepted.accept!

    assert Invitation.pending.include?(@pending)
    refute Invitation.pending.include?(@accepted)
  end

  # regression test for: https://github.com/3scale/system/pull/3316
  test 'send invitation with helper tag' do
    buyer = FactoryBot.create(:simple_buyer, provider_account: @provider)
    FactoryBot.create(:cms_email_template, system_name: 'invitation', provider: @provider, published: '{% debug:help %}', rails_view_path: 'emails/invitation')

    assert_difference('ActionMailer::Base.deliveries.count') do
      FactoryBot.create(:invitation, account: buyer)
    end
  end

end
