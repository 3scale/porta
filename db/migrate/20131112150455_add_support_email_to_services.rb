class AddSupportEmailToServices < ActiveRecord::Migration
  def self.up
    change_table :services do |s|
      s.string :support_email
    end
  end

  def self.down
    change_table :services do |s|
      s.remove :support_email
    end
  end
end
