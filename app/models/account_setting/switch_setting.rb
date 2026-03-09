# frozen_string_literal: true

class AccountSetting::SwitchSetting < AccountSetting
  VALID_VALUES = %w[denied hidden visible].freeze

  validates :value, inclusion: { in: VALID_VALUES }

  state_machine :value, initial: 'denied' do
    before_transition do |record|
      unless record.account.provider?
        raise Account::ProviderOnlyMethodCalledError, "cannot change state of #{record.type}"
      end
    end

    state 'denied', 'hidden', 'visible'

    event :allow do
      transition 'denied' => 'hidden'
    end

    event :show do
      transition 'hidden' => 'visible'
    end

    event :hide do
      transition 'visible' => 'hidden'
    end

    event :deny do
      transition ['hidden', 'visible'] => 'denied'
    end
  end

  def self.cast(value)
    value&.to_s
  end

  def self.serialize(value)
    value.to_s
  end

  def typed_value
    value
  end
end
