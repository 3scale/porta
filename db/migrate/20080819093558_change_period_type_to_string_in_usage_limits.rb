class ChangePeriodTypeToStringInUsageLimits < ActiveRecord::Migration
  def self.up
    change_table :usage_limits do |t|
      t.change :period, :string
    end
  end

  def self.down
    change_table :usage_limits do |t|
      t.change :period, :integer
    end
  end
end
