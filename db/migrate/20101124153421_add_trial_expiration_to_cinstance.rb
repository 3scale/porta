class AddTrialExpirationToCinstance < ActiveRecord::Migration
  def self.up
    add_column :cinstances, :trial_period_expires_at, :datetime

    Cinstance.reset_column_information
    Cinstance.find_each(:joins => :plan) do |cinstance|
      cinstance.send(:set_trial_period_expires_at)
      puts "#{cinstance.inspect} migrated"
    end
  end

  def self.down
    remove_column :cinstances, :trial_period_expires_at
  end
end
