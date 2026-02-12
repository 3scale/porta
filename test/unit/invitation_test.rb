require 'test_helper'

class InvitationTest < ActiveSupport::TestCase

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

  test 'enqueues a worker when created' do
    SendUserInvitationWorker.expects(:perform_later)
    @provider.invitations.create!(:email => 'buddy@example.net')
  end

  test 'sent_at field is nil when created' do
    invitation = @provider.invitations.create!(email: 'buddy@example.net')
    assert_nil invitation.sent_at
  end

  test 'resend unaccepted invitation email' do
    SendUserInvitationWorker.expects(:perform_later).twice
    @unaccepted_invitation = @provider.invitations.create!(:email => 'buddy@example.net')
    @unaccepted_invitation.resend
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

    travel_to(Time.utc(2010, 3, 12)) do
      assert_change :of => -> { invitation.accepted? }, :from => false, :to => true do
        invitation.accept!
      end

      assert_equal Time.utc(2010, 3, 12), invitation.accepted_at
    end
  end

  test 'Invitation#accept! does nothing for already accepted invitation' do
    invitation = @provider.invitations.create!(:email => 'bob@example.com')
    invitation.accept!

    travel_to(2.days.from_now) do
      assert_no_change :of => -> { invitation.accepted_at } do
        invitation.accept!
      end
    end
  end

  test 'creating invited user accepts the invitation' do
    invitation = @provider.invitations.create!(:email => 'bob@example.net')
    user = invitation.make_user(:username => 'bob', :password => 'superSecret1234#')

    assert_change :of => -> { invitation.accepted? }, :from => false, :to => true do
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
end
