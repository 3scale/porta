require 'test_helper'

class Events::Importers::AlertImporterTest < ActiveSupport::TestCase

  def setup
    Logic::RollingUpdates.expects(skipped?: true).at_least_once

    provider        = FactoryBot.create(:provider_account)
    @service        = provider.first_service!
    service_id      = @service.backend_id
    buyer           = FactoryBot.create(:buyer_account, :provider_account  => provider)
    plan            = FactoryBot.create(:application_plan, :issuer => @service)
    @cinstance      = FactoryBot.create(:cinstance, :plan => plan, :user_account => buyer)
    application_id  = @cinstance.application_id

    event_attrs = [
      { :id => 4, :service_id => service_id, :application_id => application_id,
        :timestamp => "2011-07-07 23:25:53 +0000", :max_utilization => 1.10, :utilization=> 50, :limit => "foos per month: 115 of 100"},
      { :id => 3, :service_id => service_id, :application_id => application_id,
        :timestamp => "2011-07-31 23:25:53 +0000", :max_utilization => 1.15, :utilization => 90, :limit => "foos per month: 115 of 100"},
      { :id => 2, :service_id => service_id, :application_id => application_id,
        :timestamp => "2011-07-31 23:25:53 +0000", :max_utilization => 1.25, :utilization => 120, :limit => "foos per month: 125 of 100"},
      { :id => 1, :service_id => service_id, :application_id => application_id,
        :timestamp => "2011-07-31 23:25:53 +0000", :max_utilization => 1.35, :utilization => 150, :limit => "foos per month: 115 of 100"}
    ]

    @events = event_attrs.map{ |attrs| OpenStruct.new(attrs) }

    Events::Importers::AlertImporter.clear_cache
  end

  def import_events(events = @events)
    events.each do |event|
      Events::Importers::AlertImporter.new(event).save!
    end
  end

  private :import_events

  test "save alert after destroy the cinstance should not raise error" do
    @cinstance.destroy
    @events.each do |event|
      refute Events::Importers::AlertImporter.new(event).save!
    end
  end

  test "save alerts" do
    @service.update_attribute(:notification_settings, {
      :web_buyer => [50],
      :web_provider => [50]
    })

    import_events

    assert_equal(2, Alert.count)
  end

  test 'import to database all events allowed by service settings' do
    @service.update_attribute(:notification_settings, {
      :web_buyer => [50, 90, 100],
      :web_provider => [50, 100, 150]
    })

    import_events

    # 2 events for buyer, 2 events for provider
    assert_equal 2*2, Alert.count
  end

  test 'ignore repeated alerts' do
    @service.update_attribute(:notification_settings, {
      :web_buyer => [50, 90, 100],
      :web_provider => [50, 100, 150]
    })

    import_events

    # There should be no extra alerts
    # 2 events for buyer, 2 events for provider
    assert_equal 2*2, Alert.count
  end

  test 'send emails' do
    @service.update_attribute(:notification_settings, {
      :email_buyer => [50, 90, 100],
      :email_provider => [90, 100, 150, 200]
    })

    ActionMailer::Base.deliveries = []
    import_events

    assert_equal ActionMailer::Base.deliveries.size, 4
  end

  test 'rescues errors when sending emails' do
    @service.update_attribute(:notification_settings, email_buyer: [50], email_provider: [50])

    AlertMessenger.any_instance.expects(:deliver).twice.raises(Liquid::SyntaxError)
    System::ErrorReporting.expects(:report_error).twice.with {|error| error.bugsnag_meta_data }

    assert_no_difference ActionMailer::Base.deliveries.method(:size) do
      import_events
    end
  end

  def test_publish_events
    @service.update_attribute(:notification_settings, {
      email_buyer:    [50, 100],
      email_provider: [50, 100]
    })

    Alert.any_instance.stubs(:persisted?).returns(true)

    Alerts::PublishAlertEventService.expects(:run!).twice

    import_events
  end

  def test_not_publish_events
    @service.update_attribute(:notification_settings, {
      email_buyer:    [50, 100],
      email_provider: [50, 100]
    })

    Alert.any_instance.stubs(:persisted?).returns(false)

    Alerts::PublishAlertEventService.expects(:run!).never

    import_events
  end

  def test_suspended_cinstance
    @service.update_attribute(:notification_settings, {
      email_buyer:    [50, 100],
      email_provider: [50, 100]
    })

    Events::Importers::AlertImporter.any_instance.expects(:send_email).at_least_once
    Events::Importers::AlertImporter.any_instance.expects(:publish_events).at_least_once

    import_events

    @cinstance.suspend!

    Events::Importers::AlertImporter.any_instance.expects(:send_email).never
    Events::Importers::AlertImporter.any_instance.expects(:publish_events).never

    import_events
  end

  def test_notify_segment
    master_account.first_service!.update_attribute(:notification_settings, email_provider: [50])

    ThreeScale::Analytics.expects(:track).with(
        instance_of(User),
        'Alert',
        {:alert_id => 42,
         :level => 50,
         :utilization => 1.1,
         :message => 'foos per month: 115 of 100',
         :timestamp => '2011-07-07 23:25:53 +0000'
        })

    event = OpenStruct.new(
        id: 42,
        timestamp: "2011-07-07 23:25:53 +0000",
        max_utilization: 1.10,
        utilization: 50,
        limit: "foos per month: 115 of 100",
        application_id: @service.account.bought_cinstance.application_id,
        service_id: master_account.first_service!.id
    )

    import_events([event])
  end

  def test_invalid_event_error
    @service.update_attribute(:notification_settings, {
      email_buyer:    [50, 100],
      email_provider: [50, 100]
    })

    Alert.any_instance.expects(:valid?).returns(false).twice
    System::ErrorReporting.expects(:report_error).twice

    import_events
  end
end
