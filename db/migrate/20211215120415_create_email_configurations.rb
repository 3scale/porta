class CreateEmailConfigurations < ActiveRecord::Migration[5.0]
  def change
    create_table :email_configurations do |t|
      t.string :email
      t.string :username
      t.string :password
      t.string :smtp_address_and_port
      t.bigint :tenant_id
      t.belongs_to :account
      t.timestamps
      t.index([ :account_id, :email], unique: true)
    end
  end
end
