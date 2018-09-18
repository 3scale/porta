class FixDeprecatedCinstances < ActiveRecord::Migration
  def self.up
    Cinstance.all(:conditions => {:state => 'deprecated'}).each do |cinstance|
      cinstance.update_attribute(:deleted_at,
        Time.zone.now + cinstance.contract.cancellation_period)
    end
  end

  def self.down
  end
end
