class CreateSearchTerms < ActiveRecord::Migration
  def self.up
    create_table :search_terms do |t|
      t.string :term
      t.integer :user_id
      t.string :ip_address

      t.timestamps
    end
  end

  def self.down
    drop_table :search_terms
  end
end
