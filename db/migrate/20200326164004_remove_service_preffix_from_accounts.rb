# frozen_string_literal: true

class RemoveServicePreffixFromAccounts < ActiveRecord::Migration[5.0]
  def change
    safety_assured { remove_column :accounts, :service_preffix, :string }
  end
end
