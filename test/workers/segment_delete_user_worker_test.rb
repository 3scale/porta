# frozen_string_literal: true

require 'test_helper'

class SegmentDeleteUserWorkerTest < ActiveSupport::TestCase
  setup do
    System::ErrorReporting.stubs(:report_error)
  end

  test 'perform does the right requests' do
    Segment::AuthenticatorService.expects(:request_token).with(expected_segment_requester).returns(token)

    expected_delete_user_service.expects(:call).with(expected_segment_requester)

    SegmentDeleteUserWorker.perform_now(user_deleted_event.event_id)
  end

  test 'perform raises error when there is a server error in the token request' do
    Segment::AuthenticatorService.expects(:request_token).raises(server_error)

    assert_raise(Segment::ServerError) { SegmentDeleteUserWorker.perform_now(user_deleted_event.event_id) }
  end

  test 'perform raises error when there is a server error in the delete request' do
    Segment::AuthenticatorService.expects(:request_token).returns(token)

    expected_delete_user_service.expects(:call).raises(server_error)

    assert_raise(Segment::ServerError) { SegmentDeleteUserWorker.perform_now(user_deleted_event.event_id) }
  end

  test 'perform does not raise client error for the token request but reports to bugsnag with the proper data' do
    Segment::AuthenticatorService.expects(:request_token).raises(client_error)

    System::ErrorReporting.expects(:report_error).with do |exception, options|
      exception.is_a?(Segment::ClientError) && (response = options.dig(:parameters, :response)) \
        && response[:status] == client_error.response.status && response[:body] == client_error.response.body
    end

    SegmentDeleteUserWorker.perform_now(user_deleted_event.event_id)
  end

  test 'perform does not raise client error for the delete request but reports to bugsnag with the proper data' do
    Segment::AuthenticatorService.expects(:request_token).returns(token)

    expected_delete_user_service.expects(:call).raises(client_error)

    System::ErrorReporting.expects(:report_error).with do |exception, options|
      exception.is_a?(Segment::ClientError) && (response = options.dig(:parameters, :response)) \
        && response[:status] == client_error.response.status && response[:body] == client_error.response.body
    end

    SegmentDeleteUserWorker.perform_now(user_deleted_event.event_id)
  end

  test 'perform does not raise unexpected response error for the token request but reports to bugsnag with the proper data' do
    Segment::AuthenticatorService.expects(:request_token).raises(unexpected_response_error)

    System::ErrorReporting.expects(:report_error).with do |exception, options|
      exception.is_a?(Segment::UnexpectedResponseError) && (response = options.dig(:parameters, :response)) \
        && response[:status] == unexpected_response_error.response.status && response[:body] == unexpected_response_error.response.body
    end

    SegmentDeleteUserWorker.perform_now(user_deleted_event.event_id)
  end

  test 'perform does not raise unexpected response error for the delete request but reports to bugsnag with the proper data' do
    Segment::AuthenticatorService.expects(:request_token).returns(token)

    expected_delete_user_service.expects(:call).raises(unexpected_response_error)

    System::ErrorReporting.expects(:report_error).with do |exception, options|
      exception.is_a?(Segment::UnexpectedResponseError) && (response = options.dig(:parameters, :response)) \
        && response[:status] == unexpected_response_error.response.status && response[:body] == unexpected_response_error.response.body
    end

    SegmentDeleteUserWorker.perform_now(user_deleted_event.event_id)
  end

  private

  class SimpleHTTPResponse
    def initialize(status:, body:)
      @status, @body = status, body
    end

    attr_reader :status, :body
  end

  def user_deleted_event
    @user_deleted_event ||= begin
      user = FactoryBot.create(:admin, account: provider, tenant_id: provider.id)
      event = Users::UserDeletedEvent.create(user)
      Rails.application.config.event_store.publish_event(event)
      event
    end
  end

  def provider
    @provider ||= FactoryBot.create(:simple_provider)
  end

  def token
    @token ||= 'this-is-the-token'
  end

  def expected_delete_user_service
    @expected_delete_user_service ||= begin
      segment_delete_service = Segment::DeleteUserService.new(user_deleted_event.data[:user_id], token)
      Segment::DeleteUserService.expects(:new).with(user_deleted_event.data[:user_id], token).returns(segment_delete_service)
      segment_delete_service
    end
  end

  def expected_segment_requester
    @expected_segment_requester ||= begin
      segment_requester = Segment::GBPRApiRequest.new
      Segment::GBPRApiRequest.expects(:new).returns(segment_requester)
      segment_requester
    end
  end

  def server_error
    @server_error ||= Segment::ServerError.new('message', 'response')
  end

  def client_error
    @client_error ||= Segment::ClientError.new('message', SimpleHTTPResponse.new(status: 404, body: 'Not found with this response body'))
  end

  def unexpected_response_error
    @unexpected_response_error ||= Segment::UnexpectedResponseError.new('message', SimpleHTTPResponse.new(status: 303, body: 'Unexpected status with this response body'))
  end

end
