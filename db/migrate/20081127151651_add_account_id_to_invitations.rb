class AddAccountIdToInvitations < ActiveRecord::Migration
  def self.up
    change_table :invitations do |t|
      t.belongs_to :account
    end
  end

  def self.down
    change_table :invitations do |t|
      t.remove_belongs_to :account
    end
  end
end
