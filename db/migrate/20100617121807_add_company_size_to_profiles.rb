class AddCompanySizeToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :company_size, :string
  end

  def self.down
    remove_column :profiles, :company_size
  end
end
