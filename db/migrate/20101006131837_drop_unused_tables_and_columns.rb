class DropUnusedTablesAndColumns < ActiveRecord::Migration
  def self.up
    drop_table :competitors
    drop_table :daily_reports
    drop_table :deletions
    drop_table :hourly_reports
    drop_table :reports
    drop_table :service_transactions

    # accounts
    remove_column :accounts, :acc_type

    # cinstances
    remove_column :cinstances, :userendpoint_id
    remove_column :cinstances, :cost_firstpayment_billingdate
    remove_column :cinstances, :cost_per_month_billingdate
    remove_column :cinstances, :ctrial

    # plans
    remove_column :plans, :ctrial

    # services
    remove_column :services, :url_pages_longdescription
    remove_column :services, :url_api
    remove_column :services, :url_support
    remove_column :services, :url_blog
    remove_column :services, :email_support
    remove_column :services, :api_type_soap
    remove_column :services, :api_type_rest
    remove_column :services, :api_type_xmlrpc
    remove_column :services, :api_type_javascript
    remove_column :services, :api_type_other
    remove_column :services, :featured
    remove_column :services, :wsdl_file_name
    remove_column :services, :wsdl_content_type
    remove_column :services, :wsdl_file_size
    remove_column :services, :technologies
    remove_column :services, :data_formats
  end

  def self.down
    raise ActiveRecord::IrreversableMigration
  end
end
