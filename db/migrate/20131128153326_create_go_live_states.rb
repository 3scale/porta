class CreateGoLiveStates < ActiveRecord::Migration
  def change
    create_table :go_live_states do |t|
      t.references :account, :limit => 8
      t.boolean :step1, default: false
      t.boolean :step2, default: false
      t.boolean :step3, default: false
      t.boolean :step4, default: false
      t.boolean :step5, default: false

      t.timestamps
    end
    add_index :go_live_states, :account_id
  end
end
