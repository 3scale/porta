class RemoveProviderAccountIdFromContracts < ActiveRecord::Migration
  def self.up
    execute 'ALTER TABLE contracts DROP FOREIGN KEY fk_ct_provider_account_id'
    
    change_table :contracts do |t|
      t.remove :provider_account_id
    end
  end

  def self.down
    change_table :contracts do |t|
      t.integer :provider_account_id, :null => false
    end
    
    execute 'ALTER TABLE contracts ADD CONSTRAINT fk_ct_provider_account_id FOREIGN KEY (provider_account_id) REFERENCES accounts(id)'
  end
end
