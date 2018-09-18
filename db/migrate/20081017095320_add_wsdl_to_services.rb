class AddWsdlToServices < ActiveRecord::Migration
  def self.up
    change_table :services do |t|
      t.string :wsdl_file_name
      t.string :wsdl_content_type
      t.integer :wsdl_file_size
    end
  end

  def self.down
    change_table :services do |t|
      t.remove :wsdl_file_name
      t.remove :wsdl_content_type
      t.remove :wsdl_file_size
    end
  end
end
