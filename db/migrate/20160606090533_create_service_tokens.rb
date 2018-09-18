class CreateServiceTokens < ActiveRecord::Migration
  def change
    create_table :service_tokens do |t|
      t.references :service, index: true, limit: 8
      t.string :value

      t.timestamps
    end
  end
end
