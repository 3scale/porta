class UpdateDefaultErrorForNoMatch < ActiveRecord::Migration
  def self.up
    change_column :proxies, :error_no_match, :string, :default => 'No Mapping Rule matched', :null => false

    # update existing fields with old value
    execute %{ UPDATE `proxies` SET `error_no_match` = 'No Mapping Rule matched' WHERE `proxies`.`error_no_match` = 'No rule matched' }
  end

  def self.down
    change_column :proxies, :error_no_match, :string, :default => 'No rule matched', :null => false
  end
end
