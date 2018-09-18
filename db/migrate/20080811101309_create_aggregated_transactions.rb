class CreateAggregatedTransactions < ActiveRecord::Migration
  def self.up
    [:hourly, :daily, :monthly].each do |type|
      create_table "#{type}_transactions" do |t|
        t.belongs_to :cinstance
        t.belongs_to :metric
        t.integer :value
        t.datetime :created_at
      end
    end
  end

  def self.down
    [:hourly, :daily, :monthly].each do |type|
      drop_table "#{type}_transactions"
    end
  end
end
