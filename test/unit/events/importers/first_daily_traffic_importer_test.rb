# frozen_string_literal: true

require 'test_helper'

class Events::Importers::FirstDailyTrafficImporterTest < ActiveSupport::TestCase

  def setup
    @cinstance = FactoryBot.create(:cinstance)
    @timestamp = 1.day.ago.round
    @object    = OpenStruct.new(
      application_id: @cinstance.application_id,
      service_id:     @cinstance.service.id,
      timestamp:      @timestamp.to_s
    )
  end

  test '#save!' do
    assert importer.save!

    @cinstance.reload
    assert_equal @timestamp.to_s, @cinstance.first_daily_traffic_at.to_s
  end

  test "save importer after destroy the cinstance should not raise error" do
    @cinstance.destroy
    assert_not importer.save!
  end

  test 'notify_segment' do
    @cinstance.account.update_attribute(:provider, true)
    ThreeScale::Analytics::UserTracking::Segment.expects(:track).with(has_entries(event: 'Traffic Sent',
                                                                                  properties: {
                                                                                    timestamp: @timestamp,
                                                                                      date: @timestamp.to_date
                                                                                  })).returns(true)
    LastTraffic.expects(:send_traffic_in_day).with(@cinstance, @timestamp).returns(true)

    assert_not importer.notify_segment

    assert @cinstance.update_attribute(:first_daily_traffic_at, @object.timestamp)

    assert importer.notify_segment
  end

  # Regression: https://app.bugsnag.com/3scale-networks-sl/system/errors/61ba778a71d2ed0008544c1d?event_id=622fc0e90092e226db140000&i=sk&m=fq
  test 'user_tracking is nil' do
    Events::Importers::BaseImporter.any_instance.expects(:user_tracking).returns(nil)
    Cinstance.any_instance.expects(:first_daily_traffic_at).returns(@object.timestamp)
    assert_not importer.notify_segment
  end

  protected

  def importer
    Events::Importers::FirstDailyTrafficImporter.new(@object)
  end
end
