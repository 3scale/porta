# frozen_string_literal: true

class AccountSetting::MultipleApplicationsSwitch < AccountSetting::SwitchSetting
  state_machine :value do
    after_transition to: %w[visible hidden], from: ['denied'] do |record|
      SimpleLayout.new(record.account).create_multiapp_builtin_pages!
    end
  end
end
