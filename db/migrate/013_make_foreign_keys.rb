class MakeForeignKeys < ActiveRecord::Migration
  def self.up
    #create all the foreign keys
    #NOTES - all the constraint names MUST be unique
    # the tables have to exist before these are created
    # the columns referenced must be of the same type as the referencing column
    # the DB engine should be InnoDB.
#    execute "ALTER TABLE providerendpoints ADD CONSTRAINT fk_owner_3_id FOREIGN KEY (account_id) REFERENCES accounts (id);"
#    execute "ALTER TABLE accounts ADD CONSTRAINT fk_acc_user_id foreign key (user_id) references users (id);"
    execute "ALTER TABLE profiles ADD CONSTRAINT fk_account_id foreign key (account_id) references accounts (id);"
    execute "ALTER TABLE usagestats ADD CONSTRAINT fk_cinstance_2_id foreign key (cinstance_id) references cinstances (id);"
    execute "ALTER TABLE usagestatdatas ADD CONSTRAINT fk_usagestat_id foreign key (usagestat_id) references usagestats (id);"
    execute "ALTER TABLE contracts ADD CONSTRAINT fk_ct_providerendpoint_id foreign key (providerendpoint_id) references providerendpoints (id);"
    execute "ALTER TABLE contracts ADD CONSTRAINT fk_ct_provider_account_id foreign key (provider_account_id) references accounts (id);"
    execute "ALTER TABLE cinstances ADD CONSTRAINT fk_ct_user_account_id foreign key (user_account_id) references accounts (id);"
    execute "ALTER TABLE cinstances ADD CONSTRAINT fk_ct_contract_id foreign key (contract_id) references contracts (id);"
  end

  def self.down
    #not sure these will work ....
    #in fact whenever tried they seem to silently fail. you may 
    # have to execute them in the mysql admin one by one. The SQL works...
    #
    #execute "ALTER TABLE providerendpoints DROP FOREIGN KEY fk_owner_3_id;"
    #execute "ALTER TABLE accounts DROP FOREIGN KEY fk_acc_user_id;"
    #execute "ALTER TABLE profiles DROP FOREIGN KEY fk_account_id;"
    #execute "ALTER TABLE usagestats DROP FOREIGN KEY fk_cinstance_2_id;"
    #execute "ALTER TABLE usagestatdatas DROP FOREIGN KEY fk_usagestat_id;"
    #execute "ALTER TABLE contracts DROP FOREIGN KEY fk_ct_providerendpoint_id;"
    #execute "ALTER TABLE cinstances DROP FOREIGN KEY fk_ct_userendpoint_id;"
    #execute "ALTER TABLE contracts DROP FOREIGN KEY fk_ct_provider_account_id;"
    #execute "ALTER TABLE cinstances DROP FOREIGN KEY fk_ct_user_account_id;"
    #execute "ALTER TABLE cinstances DROP FOREIGN KEY fk_ct_contract_id;"
 
  end
end
