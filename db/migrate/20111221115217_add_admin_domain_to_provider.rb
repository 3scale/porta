class AddAdminDomainToProvider < ActiveRecord::Migration
  def self.up
    add_column :accounts, :self_domain, :string
    add_index :accounts, :self_domain

    CONNECT_DOMAINS.clear
    domain = Account.master.domain
    Account.reset_column_information

    Account.providers.find_each do |p|
      p.generate_domains
      p.save!
      puts "Self domain #{p.org_name} is now #{p.self_domain}"
    end

    # Account.master.update_attribute(:self_domain, 'master.3scale.net')
  end

  def self.down
    remove_column :accounts, :self_domain
    remove_index :accounts, :self_domain
  end
end
