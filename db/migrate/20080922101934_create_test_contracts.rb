class CreateTestContracts < ActiveRecord::Migration
  def self.up
    Service.all.each(&:create_test_contract)
  end

  def self.down
  end
end
