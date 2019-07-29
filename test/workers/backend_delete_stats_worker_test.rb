# frozen_string_literal: true

require 'test_helper'

class BackendDeleteStatsWorkerTest < ActiveSupport::TestCase
  def setup
    @service = FactoryBot.create(:simple_service)
    @applications = FactoryBot.create_list(:cinstance, 3)
    applications.each { |cinstance| DeletedObject.create(owner: service, object: cinstance) }
    @metrics = FactoryBot.create_list(:metric, 3)
    metrics.each { |metric| DeletedObject.create(owner: service, object: metric) }

    @event = Services::ServiceDeletedEvent.create_and_publish!(service)
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
    deletejobdef = delete_job[:deletejobdef] || {}
    [
      -> { (deletejobdef[:applications] || []).sort == applications.map(&:id).sort },
      -> { (deletejobdef[:metrics] || []).sort == metrics.map(&:id).sort },
      -> { deletejobdef[:users] == [] },
      -> { deletejobdef[:from] == service.created_at.utc.to_i },
      -> { deletejobdef[:to] == Time.now.utc.to_i }
    ].all?(&:call)
  end
end
