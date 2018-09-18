class MoveProviderKeyFromServiceOverToProviderCinstance < ActiveRecord::Migration
  def self.up
  end

  def self.down
    Account.with_deleted.master.provided_cinstances.each do |cinstance|
      next unless cinstance.user_account && cinstance.user_account.service

      cinstance.user_account.service.provider_private_key = cinstance.user_key
      cinstance.user_account.service.save!
    end
  end
end
