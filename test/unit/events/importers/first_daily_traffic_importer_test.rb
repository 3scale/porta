require 'test_helper'

class Events::Importers::FirstDailyTrafficImporterTest < ActiveSupport::TestCase

  def setup
    @cinstance = Factory(:cinstance)
    @timestamp = 1.day.ago.round
    @object    = OpenStruct.new(
                   application_id: @cinstance.application_id,
                   service_id:     @cinstance.service.id,
                   timestamp:      @timestamp.to_s
    )
  end

  def test_save!
    assert importer.save!

    @cinstance.reload
    assert_equal @timestamp.to_s, @cinstance.first_daily_traffic_at.to_s
  end

  test "save importer after destroy the cinstance should not raise error" do
    @cinstance.destroy
    refute importer.save!
  end

  def test_notify_segment
    @cinstance.account.update_attribute(:provider, true)
    ThreeScale::Analytics::UserTracking::Segment.expects(:track).with(has_entries(event: 'Traffic Sent',
                                                                                  properties: {
                                                                                      timestamp: @timestamp,
                                                                                      date: @timestamp.to_date
                                                                                  })).returns(true)
    LastTraffic.expects(:send_traffic_in_day).with(@cinstance, @timestamp).returns(true)

    refute importer.notify_segment

    assert @cinstance.update_attribute(:first_daily_traffic_at, @object.timestamp)

    assert importer.notify_segment
  end

  protected

  def importer
    Events::Importers::FirstDailyTrafficImporter.new(@object)
  end
end
