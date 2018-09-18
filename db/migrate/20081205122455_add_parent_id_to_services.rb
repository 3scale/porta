class AddParentIdToServices < ActiveRecord::Migration
  def self.up
    add_column :services, :parent_id, :integer
    
    Service.all.each do |s|
      s.create_draft
      s.update_attribute(:updated_at, Time.now)
    end
  end

  def self.down
    remove_column :services, :parent_id
  end
end
