class CreateCinstances < ActiveRecord::Migration
  def self.up
    create_table :cinstances do |t|
      t.column :id, :int, :null => false, :autoincrement => true
      
      #this is the class this instance belongs to
      t.column :contract_id, :int, :null => false
      
      #the user creating this contract.
      t.column :userendpoint_id, :int
      t.column :user_account_id, :int
      
      #security keys
      t.column :sec_userkey, :string
      t.column :sec_providerkey, :string
      
      #billing information
      t.column :cost_firstpayment_billingdate, :datetime
      t.column :cost_per_month_billingdate, :datetime
      
      #status
      t.column :cistatus, :string, :default => 'LIVE' #other values: COMPLETE
      t.column :ctrial, :boolean, :default => false
      t.column :viewstatus, :string, :default => 'PRIVATE'
      
      #timestamps
      t.timestamps
    end
  end

  def self.down
    execute "SET FOREIGN_KEY_CHECKS=0"
    drop_table :cinstances
    execute "SET FOREIGN_KEY_CHECKS=1"
  end
end
