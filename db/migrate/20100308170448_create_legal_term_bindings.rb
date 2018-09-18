class CreateLegalTermBindings < ActiveRecord::Migration
  def self.up
    create_table :legal_term_bindings do |t|
      t.references :legal_term
      t.integer    :legal_term_version
      t.string     :resource_type
      t.integer    :resource_id

      t.timestamps
    end
  end

  def self.down
    drop_table :legal_term_bindings
  end
end
