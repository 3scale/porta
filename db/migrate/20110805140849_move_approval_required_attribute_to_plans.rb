class MoveApprovalRequiredAttributeToPlans < ActiveRecord::Migration
  def self.up
    
    change_table Plan.table_name do |t|
        t.boolean :approval_required, :null => false, :default => false
    end
    
    execute %{
      UPDATE plans 
      LEFT JOIN services ON services.id = plans.issuer_id AND plans.issuer_type = "Service"
      SET plans.approval_required = services.approval_required WHERE services.approval_required IS NOT NULL;
    }
    execute %{
      UPDATE plans 
      LEFT JOIN services ON services.account_id = plans.issuer_id AND plans.issuer_type = "Account"
      SET plans.approval_required = services.approval_required WHERE services.approval_required IS NOT NULL;
    }

    change_table Service.table_name do |t|
      t.remove :approval_required
    end
    
  end

  def self.down
    
    change_table Service.table_name do |t|
      t.boolean :approval_required, :null => false, :default => false
    end
    
    %{
      UPDATE services
      LEFT JOIN plans on plans.issuer_type = "Service" AND plans.issuer_id = services.id AND plans.type = "ApplicationPlan"
      SET services.approval_required = 1
      WHERE plans.approval_required = 1;
    }
    
    change_table Plan.table_name do |t|
      t.remove :approval_required
    end
    
  end
end
