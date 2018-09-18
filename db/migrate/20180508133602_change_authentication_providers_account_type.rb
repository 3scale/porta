# frozen_string_literal: true

class ChangeAuthenticationProvidersAccountType < ActiveRecord::Migration
  def up
    change_column_default(:authentication_providers, :account_type, 'developer')
    update_account_type_value(:downcase)
  end

  def down
    change_column_default(:authentication_providers, :account_type, 'Developer')
    update_account_type_value(:capitalize)
  end

  def update_account_type_value(word_change)
    AuthenticationProvider.all.find_in_batches(batch_size: 100).each do |authentication_provider_group|
      authentication_provider_group.each do |authentication_provider|
        current_account_type = authentication_provider.read_attribute_before_type_cast('account_type')
        authentication_provider.update_column(:account_type, current_account_type.public_send(word_change))
      end
    end
  end
end
