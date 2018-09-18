class PrematureBurial < ActiveRecord::Migration
  def self.up
    paranoid = "deleted_at IS NOT NULL"
    Account.delete_all paranoid
    Contract.delete_all paranoid
    Plan.delete_all paranoid
    Service.delete_all paranoid
    User.delete_all paranoid
  end

  def self.down
  end
end
