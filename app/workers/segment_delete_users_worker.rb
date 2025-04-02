# frozen_string_literal: true

class SegmentDeleteUsersWorker < ApplicationJob

  queue_as :low

  # :reek:FeatureEnvy can be ignored here for the 'response'
  def perform
    return unless Features::SegmentDeletionConfig.enabled?
    config = Features::SegmentDeletionConfig.config
    DeletedObject.users.select(:id, :object_id).order(:id).find_in_batches(batch_size: config.request_size) do |records|
      SegmentIntegration::DeleteUsersService.call(records.map(&:object_id))
      records.each(&DeleteObjectHierarchyWorker.method(:delete_later))
      sleep(config.wait_time)
    end
  rescue SegmentIntegration::ClientError, SegmentIntegration::UnexpectedResponseError => error
    response = error.response
    System::ErrorReporting.report_error(error, parameters: {response: {status: response.status, body: response.body}})
  end

end
