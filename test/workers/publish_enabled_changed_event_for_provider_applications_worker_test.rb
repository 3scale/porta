require 'test_helper'
class PublishEnabledChangedEventForProviderApplicationsWorkerTest < ActiveSupport::TestCase
  def setup
    @provider = FactoryBot.create(:provider_account)
    service = provider.services.first!
    service.service_tokens.create!(value: 'token')
    plan = FactoryBot.create(:application_plan, service: service)
    buyer = FactoryBot.create(:buyer_account, provider_account: provider)
    buyer.buy! plan
    provider.reload
  end

  attr_reader :provider

  def test_perform_when_current_state_scheduled_for_deletion
    provider.schedule_for_deletion!
    Cinstance.any_instance.expects(:publish_enabled_changed_event).times(provider.buyer_applications.count + provider.bought_cinstances.count)
    PublishEnabledChangedEventForProviderApplicationsWorker.new.perform(provider, 'approved')
  end

  def test_perform_when_previous_state_scheduled_for_deletion
    Cinstance.any_instance.expects(:publish_enabled_changed_event).times(provider.buyer_applications.count + provider.bought_cinstances.count)
    PublishEnabledChangedEventForProviderApplicationsWorker.new.perform(provider, 'scheduled_for_deletion')
  end

  def test_perform_when_never_scheduled_for_deletion
    provider.make_pending!
    Cinstance.any_instance.expects(:publish_enabled_changed_event).never
    PublishEnabledChangedEventForProviderApplicationsWorker.new.perform(provider, 'approved')
  end
end
