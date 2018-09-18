class SystemNameUniqueIndex < ActiveRecord::Migration
  def self.up
    [ Plan, Service, ApplicationPlan, ServicePlan, AccountPlan ].each do |model|
      model.find_each do |r|
        unless r.valid?
          new = "#{r.system_name}_#{SecureRandom.hex(2)}"
          puts "Changing #{model.to_s} #{r.system_name} to #{new}"
          r.system_name = new
          r.save!
        end
      end
    end

    add_index( :plans, [ :system_name, :type, :issuer_id, :tenant_id, :deleted_at ], :unique => true)
    add_index( :services, [ :system_name, :account_id, :deleted_at ], :unique => true)
  end

  def self.down
    remove_index( :plans, [ :system_name, :type, :issuer_id, :tenant_id, :deleted_at ])
    remove_index( :services, [ :system_name, :account_id, :deleted_at ])
  end
end
