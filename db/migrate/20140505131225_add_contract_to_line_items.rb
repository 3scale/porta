class AddContractToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :contract_id, :integer
    add_column :line_items, :contract_type, :string
  end
end
