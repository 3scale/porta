# frozen_string_literal: true

class RemoveAccountsDeletedAt < ActiveRecord::Migration[5.0]
  INDEX_COLUMNS = [
    %i[state deleted_at],
    %i[self_domain deleted_at],
    %i[domain deleted_at]
  ].freeze

  def up
    return unless column_exists?(:accounts, :deleted_at)

    INDEX_COLUMNS.each do |index_columns|
      remove_index(:accounts, index_columns) if index_exists?(:accounts, index_columns)
    end

    safety_assured { remove_column :accounts, :deleted_at }
  end

  def down
    add_column :accounts, :deleted_at, :datetime

    INDEX_COLUMNS.each { |index_columns| add_index(:accounts, index_columns) }
  end
end
