# frozen_string_literal: true

module Segment
  class DeleteUserService
    def initialize(user_id, token)
      @user_id = user_id
      @token = token
    end

    attr_reader :user_id, :token

    def call(requester = GBPRApiRequest.new)
      response = requester.call(request_body: request_body, custom_headers: {'Authorization' => "Bearer #{token}"})
      response.body
    end

    private

    def request_body
      <<~GRAPHQL
        {\"query\":
          \"mutation { createWorkspaceRegulation(workspaceSlug: \\\"#{Features::SegmentDeletionConfig.config.workspace}\\\" type: SUPPRESS_AND_DELETE userId: \\\"#{user_id}\\\" ) { id } }\"
        }
      GRAPHQL
    end
  end
end
