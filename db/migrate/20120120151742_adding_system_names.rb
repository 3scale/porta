class AddingSystemNames < ActiveRecord::Migration
  def self.up
    add_column :services, :system_name, :string
    add_column :plans, :system_name, :string

    Plan.reset_column_information
    Service.reset_column_information

    [ Plan, Service ].each do |clazz|
      clazz.find_each(:with_deleted => true) do |model|
        begin
          puts "#{clazz.to_s} '#{model.name}...'"
          model.generate_system_name
          model.save!
        rescue
          new = "#{model.system_name}_#{SecureRandom.hex(4)}"
          puts "Changing #{model.to_s} #{model.system_name} to #{new}"
          model.system_name = new
          model.name = model.system_name if model.name.blank? # the connect db is weird
          model.save!
        end
      end
    end

    change_column :services, :system_name, :string, :null => false
    change_column :plans, :system_name, :string, :null => false
  end

  def self.down
    remove_column :services, :system_name
    remove_column :plans, :system_name
  end
end
