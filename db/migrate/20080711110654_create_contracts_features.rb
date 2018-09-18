class CreateContractsFeatures < ActiveRecord::Migration
  def self.up
    create_table :contracts_features, :id => false do |t|
      t.integer :contract_id
      t.integer :feature_id
    end

    change_table :contracts_features do |t|
      t.index [:contract_id, :feature_id], :unique => true
    end
  end

  def self.down
    drop_table :contracts_features
  end
end
