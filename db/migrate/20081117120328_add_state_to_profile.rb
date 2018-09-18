class AddStateToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :state, :string

    Profile.all.each do |p|
      p.update_attribute(:state, 'published') if p.account
    end
  end

  def self.down
    remove_column :profiles, :state
  end
end
