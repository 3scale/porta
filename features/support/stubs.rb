# frozen_string_literal: true

Before do
  Aws.config[:s3] = { stub_responses: true }
end
