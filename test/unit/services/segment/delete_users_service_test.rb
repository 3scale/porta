# frozen_string_literal: true

require 'test_helper'

class SegmentIntegration::DeleteUsersServiceTest < ActiveSupport::TestCase
  class RightResponseTest < SegmentIntegration::DeleteUsersServiceTest
    test '#call does the right request to delete' do
      request = delete_request(status: 200)

      assert SegmentIntegration::DeleteUsersService.call(user_ids)
      assert_requested request
    end

    test '#call does nothing if the config is disabled' do
      Features::SegmentDeletionConfig.stubs(enabled?: false) do
        refute SegmentIntegration::DeleteUsersService.call(user_ids)
      end
    end
  end

  class WrongResponseTest < SegmentIntegration::DeleteUsersServiceTest
    test 'server error' do
      delete_request(status: 500)
      assert_raise(::SegmentIntegration::ServerError) { SegmentIntegration::DeleteUsersService.call(user_ids) }
    end

    test 'client error' do
      delete_request(status: 400)
      assert_raise(::SegmentIntegration::ClientError) { SegmentIntegration::DeleteUsersService.call(user_ids) }
    end

    test 'any other status' do
      delete_request(status: 300)
      assert_raise(::SegmentIntegration::UnexpectedResponseError) { SegmentIntegration::DeleteUsersService.call(user_ids) }
    end
  end

  private

  def delete_request(status:)
    uri = "#{config.root_uri}/workspaces/#{config.workspace}/#{config.api}"
    stub_request(:post, uri).with(
        body: stubbed_request_body,
        headers: {'Authorization'=>"Bearer #{config.token}", 'Content-Type'=>'application/json; charset=utf-8'}).
      to_return(status: status, body: 'body response')
  end

  def stubbed_request_body
    {
      regulation_type: 'Suppress_With_Delete',
      attributes: {
        name: 'userId',
        values: user_ids.map(&:to_s)
      }
    }.to_json
  end

  def user_ids
    [1, 2, 3]
  end

  def config
    @config ||= Features::SegmentDeletionConfig.configure({
      enabled: true,
      token: 'TOKEN',
      root_uri: 'https://platform.segmentapis.com/v1beta',
      workspace: 'my-workspace',
      api: 'regulations'
    }).config
  end
end
