class AddTermsToServices < ActiveRecord::Migration
  def self.up
    add_column :services, :terms, :text
  end

  def self.down
    remove_column :services, :terms
  end
end
