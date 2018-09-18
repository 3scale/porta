# frozen_string_literal: true

class AddIndexStateDeletedAtToAccounts < ActiveRecord::Migration
  def change
    add_index :accounts, %i[state deleted_at]
  end
end
