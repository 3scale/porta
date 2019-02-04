# frozen_string_literal: true

require 'test_helper'

class SegmentDeleteServiceTest < ActiveSupport::TestCase
  test '#delete_user does the right request to segment' do
    user = FactoryBot.build_stubbed(:admin, account: FactoryBot.build_stubbed(:simple_account))
    event = Users::UserDeletedEvent.create(user)
    Rails.application.config.event_store.publish_event(event)

    stub_request(:post, "https://gdpr.segment.com/graphql").
        with(body: "{\"query\":\"mutation { createWorkspaceRegulation(workspaceSlug: \\\"3scale\\\" type: SUPPRESS_AND_DELETE userId: \\\"#{user.id}\\\" ) { id } }\"}",
             headers: {'Authorization'=>'Bearer token-example', 'Content-Type'=>'application/json; charset=utf-8'})
        .to_return(status: 200, body: '{"foo": "bar"}', headers: {})


    SegmentDeleteService.delete_user(event)
  end
end
