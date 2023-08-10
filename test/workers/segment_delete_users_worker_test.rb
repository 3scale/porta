# frozen_string_literal: true

require 'test_helper'

class SegmentDeleteUsersWorkerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    FactoryBot.build_stubbed_list(:admin, 2).map do |user|
      DeletedObject.create!(object: user, owner: user.account)
    end
    Features::SegmentDeletionConfig.stubs(enabled?: true)
  end

  test 'perform does the requests and removes the objects' do
    SegmentIntegration::DeleteUsersService.expects(:call)

    number_deleted_users = DeletedObject.users.count
    assert_change of: lambda { DeletedObject.users.count }, from: number_deleted_users, to: 0 do
      perform_enqueued_jobs(only: [DeleteObjectHierarchyWorker, DeletePlainObjectWorker]) do
        SegmentDeleteUsersWorker.new.perform
      end
    end
  end

  test 'perform does not do anything is the config is disabled' do
    Features::SegmentDeletionConfig.stubs(enabled?: false)

    SegmentIntegration::DeleteUsersService.expects(:call).never

    number_deleted_users = DeletedObject.users.count
    assert_no_change of: lambda { DeletedObject.users.count }, from: number_deleted_users, to: 0 do
      perform_enqueued_jobs(only: [DeleteObjectHierarchyWorker, DeletePlainObjectWorker]) do
        SegmentDeleteUsersWorker.new.perform
      end
    end
  end

  test 'perform does the call with the users ids using the config batches size' do
    config = Features::SegmentDeletionConfig.configure(enabled: true, request_size: 3, wait_time: 5).config
    FactoryBot.build_stubbed_list(:admin, 10).each { |user| DeletedObject.create!(object: user, owner: user.account) }

    DeletedObject.users.order(:id).select(:id, :object_id).map(&:object_id).in_groups_of(config.request_size) do |expected_user_ids|
      SegmentIntegration::DeleteUsersService.expects(:call).with(expected_user_ids)
    end

    SegmentDeleteUsersWorker.new.perform
  end

  test 'perform raises error when there is a server error' do
    SegmentIntegration::DeleteUsersService.expects(:call).raises(SegmentIntegration::ServerError.new('message', 'response'))

    assert_raises(SegmentIntegration::ServerError) { SegmentDeleteUsersWorker.new.perform }
  end

  test 'perform does not raise client error but reports to bugsnag with the proper data' do
    client_error = SegmentIntegration::ClientError.new('message', SimpleHTTPResponse.new(status: 404, body: 'Not found with this response body'))
    SegmentIntegration::DeleteUsersService.expects(:call).raises(client_error)

    System::ErrorReporting.expects(:report_error).with do |exception, options|
      exception.is_a?(SegmentIntegration::ClientError) && (response = options.dig(:parameters, :response)) \
        && response[:status] == client_error.response.status && response[:body] == client_error.response.body
    end

    SegmentDeleteUsersWorker.new.perform
  end

  test 'perform does not raise unexpected response error but reports to bugsnag with the proper data' do
    unexpected_response_error = SegmentIntegration::UnexpectedResponseError.new('message', SimpleHTTPResponse.new(status: 303, body: 'Unexpected status with this response body'))
    SegmentIntegration::DeleteUsersService.expects(:call).raises(unexpected_response_error)

    System::ErrorReporting.expects(:report_error).with do |exception, options|
      exception.is_a?(SegmentIntegration::UnexpectedResponseError) && (response = options.dig(:parameters, :response)) \
        && response[:status] == unexpected_response_error.response.status && response[:body] == unexpected_response_error.response.body
    end

    SegmentDeleteUsersWorker.new.perform
  end

  class SimpleHTTPResponse
    def initialize(status:, body:)
      @status, @body = status, body
    end

    attr_reader :status, :body
  end
  private_constant :SimpleHTTPResponse

end
