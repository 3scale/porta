class DenormalizeServiceTags < ActiveRecord::Migration
  def self.up
    # Just resave each service to force tag denormalization.
    Service.all(&:save)
  end

  def self.down
  end
end
