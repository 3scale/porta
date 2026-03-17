# frozen_string_literal: true

class AccountSetting::SwitchSetting < AccountSetting
  self.default_value = 'denied'
  self.non_null = true

  def state
    return 'denied' if globally_denied? || !value

    value
  end

  def state=(new_state)
    self.value = new_state
  end

  state_machine :state, initial: 'denied' do
    before_transition do |record|
      throw :halt if record.globally_denied?
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

  def typed_assign(raw_value)
    target = raw_value.to_s
    return if state == target

    case target
    when 'denied' then deny
    when 'hidden' then state == 'denied' ? allow : hide
    when 'visible' then show
    end
  end

  def allowed?
    !denied?
  end

  def hideable?
    !globally_denied? && Settings.basic_hidden_switches.exclude?(setting_name)
  end

  def globally_denied?
    false
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

  def setting_name
    self.class.sti_name.delete_suffix('Switch').underscore.to_sym
  end
end
