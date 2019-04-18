# frozen_string_literal: true

class SegmentDeleteUserWorker < ActiveJob::Base # rubocop:disable Rails/ApplicationJob # That would be Rails 5 :)
  def perform(event_id)
    event = EventStore::Repository.find_event!(event_id)
    token = Segment::AuthenticatorService.request_token
    Segment::DeleteUserService.new(event.data[:user_id], token).call
  rescue Segment::ClientError, Segment::UnexpectedResponseError => error
    response = error.response
    System::ErrorReporting.report_error(error, parameters: {response: {status: response.status, body: response.body}})
  end
end
