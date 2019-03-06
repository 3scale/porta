# frozen_string_literal: true

require 'test_helper'

class BackendDeleteStatsWorkerTest < ActiveSupport::TestCase
  def setup
    @service = FactoryBot.create(:simple_service)
    @applications = FactoryBot.create_list(:cinstance, 3)
    applications.each { |cinstance| DeletedObjectEntry.create(owner: service, object: cinstance) }
    @metrics = FactoryBot.create_list(:metric, 3)
    metrics.each { |metric| DeletedObjectEntry.create(owner: service, object: metric) }

    @event = Services::ServiceDeletedEvent.create(service)
    Rails.application.config.event_store.publish_event(event)
  end

  attr_reader :service, :applications, :metrics, :event

  test 'perform' do
    Timecop.freeze do
      ThreeScale::Core::Service.expects(:delete_stats).with do |service_id, delete_job|
        service_id == service.id && assert_delete_job_params(delete_job)
      end

      Sidekiq::Testing.inline! { BackendDeleteStatsWorker.perform_async(event.event_id) }
    end
  end

  private

  def assert_delete_job_params(delete_job)
    return false unless delete_job.is_a? Hash
    return false if (delete_job[:applications] || []).sort != applications.map(&:id).sort
    return false if (delete_job[:metrics] || []).sort != metrics.map(&:id).sort
    return false if delete_job[:users] != []
    return false if delete_job[:from] != service.created_at.utc.to_i
    return false if delete_job[:to] != Time.now.utc.to_i
    true
  end
end
