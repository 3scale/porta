# frozen_string_literal: true

require 'test_helper'

class AuditLogServiceTest < ActiveSupport::TestCase
  test "messages are logged" do
    Rails.logger.expects(:info).with { |val| val == "[AUDIT]: sample message" }

    AuditLogService.call("sample message")
  end
end
