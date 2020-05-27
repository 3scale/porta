# frozen_string_literal: true

module CurrenciesLoader
  REQUIRED_CURRENCIES = {
    'USD - American Dollar' => 'USD',
    'EUR - Euro' => 'EUR'
  }.freeze

  module_function

  def load_config
    REQUIRED_CURRENCIES.reverse_merge(ThreeScale.config.currencies.stringify_keys)
  end
end
