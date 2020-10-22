# frozen_string_literal: true

Given "service discovery is {enabled}" do |enabled|
  ThreeScale.config.service_discovery.stubs(enabled: enabled)
end
