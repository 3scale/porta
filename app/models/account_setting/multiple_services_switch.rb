# frozen_string_literal: true

class AccountSetting::MultipleServicesSwitch < AccountSetting::SwitchSetting
  MULTISERVICES_MAX_SERVICES = 3

  state_machine :value do
    after_transition to: %w[visible hidden], from: ['denied'] do |record|
      SimpleLayout.new(record.account).create_multiservice_builtin_pages!

      record.account.update_provider_constraints_to(
        { max_services: MULTISERVICES_MAX_SERVICES },
        'Upgrading max_services because of switch is enabled.'
      )
    end
  end
end
