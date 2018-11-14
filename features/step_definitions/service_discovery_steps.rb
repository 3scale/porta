Given(/^service discovery is (not )?enabled$/) do |disabled|
  ThreeScale.config.service_discovery.stubs(enabled: disabled.blank?)
end
