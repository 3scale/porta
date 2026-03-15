# frozen_string_literal: true

class AccountSetting::FinanceSwitch < AccountSetting::SwitchSetting
  state_machine :value do
    after_transition to: 'denied', from: %w[hidden visible] do |record|
      record.account.billing_strategy&.destroy
    end

    after_transition to: %w[visible hidden], from: ['denied'] do |record|
      unless record.account.billing_strategy
        account = record.account
        account.billing_strategy = Finance::PostpaidBillingStrategy.create(account: account, currency: 'USD')
        account.save!
      end
    end
  end
end
