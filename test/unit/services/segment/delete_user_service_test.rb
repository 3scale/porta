# frozen_string_literal: true

require 'test_helper'

class Segment::DeleteUserServiceTest < ActiveSupport::TestCase
  def setup
    @user = FactoryBot.build_stubbed(:admin)
    @delete_user_service = Segment::DeleteUserService.new(user.id, 'TOKEN')
    @config = {'enabled' => true, 'email' => 'email@example.com', 'password' => 'example-password', 'uri' => 'https://gdpr.example.com/graphql', 'workspace' => 'workspace'}
    Features::SegmentDeletionConfig.configure(config)
  end

  attr_reader :user, :delete_user_service, :config

  class RightResponseTest < Segment::DeleteUserServiceTest
    attr_reader :user, :delete_user_service, :config

    test '#call does the right request to delete' do
      request = delete_request(status: 200)

      assert delete_user_service.call
      assert_requested request
    end

    test '#call does nothing when the feature is disabled' do
      request = delete_request(status: 200)

      Features::SegmentDeletionConfig.stubs(enabled?: false)

      delete_user_service.call
      assert_not_requested request
    end
  end

  class WrongResponseTest < Segment::DeleteUserServiceTest
    test 'server error' do
      delete_request(status: 500)
      assert_raise(::Segment::ServerError) { delete_user_service.call }
    end

    test 'client error' do
      delete_request(status: 400)
      assert_raise(::Segment::ClientError) { delete_user_service.call }
    end

    test 'any other status' do
      delete_request(status: 300)
      assert_raise(::Segment::UnexpectedResponseError) { delete_user_service.call }
    end
  end

  private

  def delete_request(status:, body: 'body response')
    stub_request(:post, config['uri']).
      with(body: stubbed_request_body,
           headers: {'Authorization'=>'Bearer TOKEN', 'Content-Type'=>'application/json; charset=utf-8'}).
      to_return(status: status, body: body)
  end

  def stubbed_request_body
    <<~GRAPHQL
      {\"query\":
        \"mutation { createWorkspaceRegulation(workspaceSlug: \\\"#{config['workspace']}\\\" type: SUPPRESS_AND_DELETE userId: \\\"#{user.id}\\\" ) { id } }\"
      }
    GRAPHQL
  end
end
