class CreateOnboardings < ActiveRecord::Migration
  def change
    create_table :onboardings do |t|
      t.references :account
      t.string :wizard_state
      t.string :bubble_api_state
      t.string :bubble_metric_state
      t.string :bubble_deployment_state
      t.integer :account_id, limit: 8

      t.timestamps

    end
    
    add_index :onboardings, :account_id
  end
end
