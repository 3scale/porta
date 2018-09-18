class DisallowNullValuesInAggregatedReports < ActiveRecord::Migration
  def self.up
    [:hourly, :daily, :monthly].each do |type|
      execute("UPDATE #{type}_reports SET value = 0 WHERE value IS NULL")

      change_table "#{type}_reports" do |t|
        t.change(:value, :integer, :null => false, :default => 0)
      end
    end
  end

  def self.down
    [:hourly, :daily, :monthly].each do |type|
      change_table "#{type}_reports" do |t|
        t.change(:value, :integer, :null => true, :default => nil)
      end
    end
  end
end
