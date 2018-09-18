class AddSetupFeeOnCinstance < ActiveRecord::Migration
  def self.up
    add_column :cinstances, :setup_fee, :decimal, :precision => 20, :scale => 2, :default => 0.0

    Cinstance.reset_column_information
 
    Cinstance.find_each(:joins => :plan) do |cinstance|
      cinstance.send(:set_setup_fee)
      puts "#{cinstance.inspect} migrated"
    end
    
  end

  def self.down
    remove_column :cinstances, :setup_fee
  end
end
