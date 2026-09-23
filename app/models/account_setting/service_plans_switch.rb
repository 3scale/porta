# frozen_string_literal: true

class AccountSetting::ServicePlansSwitch < AccountSetting::SwitchSetting
  state_machine :state do
    after_transition to: %w[visible hidden], from: ['denied'] do |record|
      SimpleLayout.new(record.account).create_service_plans_builtin_pages!
    end
  end
end
