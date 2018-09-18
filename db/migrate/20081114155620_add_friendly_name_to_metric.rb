class AddFriendlyNameToMetric < ActiveRecord::Migration
  def self.up
    add_column :metrics, :friendly_name, :string
    
    # we need a value, so copy over the name field.  
    Metric.all.each do |m|
      m.update_attributes(:friendly_name => m.name)
    end
  
  end

  def self.down
    remove_column :metrics, :friendly_name
  end
end
