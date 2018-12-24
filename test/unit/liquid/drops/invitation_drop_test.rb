require 'test_helper'

class Liquid::Drops::InvitationDropTest < ActiveSupport::TestCase
  include Liquid
  include DeveloperPortal::Engine.routes.url_helpers

  def setup
    @invitation = FactoryBot.build_stubbed(:invitation)
    @drop = Drops::Invitation.new(@invitation)
  end

  should 'returns email' do
    assert_equal @invitation.email, @drop.email
  end

  should 'returns accepted?' do
    @invitation.stubs :accepted? => true
    assert @drop.accepted?

    @invitation.stubs :accepted? => false
    assert !@drop.accepted?
  end

  should 'returns accepted_at' do
    time = Time.now
    @invitation.stubs  accepted_at: time
    assert_equal time, @drop.accepted_at
  end

  should 'returns sent_at' do
    created_at = Time.now
    sent_at = created_at + 5.minutes

    @invitation.stubs sent_at: nil, created_at: created_at
    assert_equal created_at, @drop.sent_at

    @invitation.stubs sent_at: sent_at
    assert_equal sent_at, @drop.sent_at
  end

  should 'returns the url for resend the invitation' do
    @invitation.stubs id: 42
    assert_equal resend_admin_account_invitation_path(@invitation), @drop.resend_url
  end

  should 'returns the resource url' do
    @invitation.stubs id: 42
    assert_equal admin_account_invitation_path(@invitation), @drop.url
  end
end
