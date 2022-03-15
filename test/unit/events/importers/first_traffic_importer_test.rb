# frozen_string_literal: true

require 'test_helper'

class Events::Importers::FirstTrafficImporterTest < ActiveSupport::TestCase

  def setup
    @cinstance = FactoryBot.create(:cinstance)
    service = @cinstance.service

    @timestamp = 1.day.ago.round

    @object = OpenStruct.new(
      application_id: @cinstance.application_id,
      service_id: service.id,
      timestamp: @timestamp.to_s
    )
  end

  def test_save!
    assert importer.save!

    @cinstance.reload
    assert_equal @timestamp.to_s, @cinstance.first_traffic_at.to_s
  end

  test "save importer after destroy the cinstance should not raise error" do
    @cinstance.destroy
    assert_not importer.save!
  end


  def test_notify_segment
    @cinstance.account.update_attribute(:provider, true)
    ThreeScale::Analytics::UserTracking::Segment.expects(:track).with(has_entries(event: 'Traffic Sent',
                                                                                  properties: {
                                                                                    timestamp: @object.timestamp,
                                                                                      date: @object.timestamp.to_date
                                                                                  })).returns(true)

    assert_not importer.notify_segment

    assert @cinstance.update_attribute(:first_traffic_at, @object.timestamp)

    assert importer.notify_segment
  end

  # Regression: https://app.bugsnag.com/3scale-networks-sl/system/errors/61ba778a71d2ed0008544c1d?event_id=622fc0e90092e226db140000&i=sk&m=fq
  test 'user_tracking is nil' do
    Events::Importers::BaseImporter.any_instance.expects(:user_tracking).returns(nil)
    Cinstance.any_instance.expects(:first_traffic_at).returns(@object.timestamp)
    assert_not importer.notify_segment
  end

  protected

  def importer
    Events::Importers::FirstTrafficImporter.new(@object)
  end
end
