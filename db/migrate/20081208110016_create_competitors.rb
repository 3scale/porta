class CreateCompetitors < ActiveRecord::Migration
  def self.up
    create_table :competitors do |t|
      t.text :email

      t.timestamps
    end
  end

  def self.down
    drop_table :competitors
  end
end
