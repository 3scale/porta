class Revival < Thor

  BUYER_ASSOCIATIONS = [
    :audits,
    :bought_account_contract,
    :bought_account_plan,
    :bought_application_plans,
    :bought_cinstances,
    :bought_plans,
    :bought_service_contracts,
    :bought_service_plans,
    :contracts,
    :features,
    :groups,
    :hidden_messages,
    :invitations,
    :invoices,
    :mail_dispatch_rules,
    :messages,
    :onboarding,
    :payment_transactions,
    :permissions,
    :profile,
    :received_messages,
    :sent_messages,
    :users
  ].freeze

  SERVICE_ASSOCIATIONS = [
    { service_plans: [:service_contracts] },
    :application_plans,
    { end_user_plans: [:plan_limits]},
    { proxy: :proxy_rules },
    { issued_plans: [:cinstances, :contracts, :usage_limits, :pricing_rules, :plan_metrics, :features_plans, :customizations] },
    { cinstances: [:alerts, :line_items, :referer_filters, :application_keys] },
    :features,
    :metrics,
    :top_level_metrics,
    :service_tokens
  ].freeze

  class_option :backup_spec, aliases: ['-f', '--from'], desc: 'Where you GET your data from', default: :backup_production, type: :string
  class_option :live_spec, aliases: ['-t', '--to'], desc: 'Where you PUT your data to', default: :development, type: :string

  desc 'developer_account ACCOUNT_ID', 'Restore a developer account from a snapshot'
  def developer_account(account_id)
    require './config/environment'
    # Connect to the backup base to get the data
    connect_to_backup do
      developer_account = Account.where(id: account_id).first
      unless developer_account.try!(:buyer?)
        warning "ACCOUNT_ID '#{account_id}' is not a developer account"
        return
      end
      restore_records([developer_account])
      BUYER_ASSOCIATIONS.each do |association_name|
        restore_associations(developer_account, association_name)
      end
    end
  end

  desc 'service SERVICE_ID', 'Restore a service from a snapshot'

  def service(service_id)
    require './config/environment'
    connect_to_backup do
      service = Service.where(id: service_id).first
      restore_records([service])
      SERVICE_ASSOCIATIONS.each do |association_name|
        deep_restore_associations(service, association_name)
      end
    end
  end

  protected

  def deep_restore_associations(record, association_name_or_hash)
    if association_name_or_hash.is_a?(Hash)
      association_name_or_hash.each do |association_name, dependent_associations|
        restore_associations(record, association_name)
        scope = record.association(association_name).scope
        scope.each do |record|
          Array(dependent_associations).each do |association_name|
            deep_restore_associations(record, association_name)
          end
        end
      end
    else
      restore_associations(record, association_name_or_hash)
    end
  end

  def restore_associations(record, association_name)
    connect_to_backup do
      association = record.association(association_name)
      reflection = association.reflection
      scope = association.scope
      return if reflection.options[:through] && [:has_many, :has_one].include?(reflection.macro)
      case reflection.macro
        when :has_and_belongs_to_many
          insert_many_to_many_associations(record, reflection)
        when :has_many, :has_one
          records = [*scope.all]
          restore_records(records)
        else # belongs_to, has_many through, :aggregate
          warning "Nothing to do with #{reflection.macro} #{reflection.name} association"
      end
    end
  end

  # We can use the HasAndBelongsToManyAssociation#insert_record method as it does not invoke save if it is not a new record
  def insert_many_to_many_associations(record, reflection)
    return unless reflection.macro == :has_and_belongs_to_many
    association_proxy = record.public_send reflection.name
    connect_to_live do
      association_proxy.insert_record(record)
    end
  end

  def restore_records(records)
    connect_to_live do
      records.each do |record|
        next if record.new_record?

        if record.class.exists?(record.id)
          warning "UPDATING #{record.class}##{record.id} in LIVE environment is forbidden"
          # Do not override existing data!
          # record.update_columns record.attributes
        else
          log "INSERTING #{record.class}##{record.id} in LIVE environment"
          # This does not invoke save, so no callbacks or validations are run
          record.class.all.insert(record.send(:arel_attributes_with_values, record.attribute_names))
        end
      end
    end
  end

  def switch_and_restore_connection(next_spec)
    current_config = ActiveRecord::Base.connection_config
    ActiveRecord::Base.establish_connection next_spec
    yield if block_given?
    ActiveRecord::Base.establish_connection current_config
  end

  def connect_to_backup(&block)
    switch_and_restore_connection options[:backup_spec].to_sym, &block
  end

  def connect_to_live(&block)
    switch_and_restore_connection options[:live_spec].to_sym, &block
  end

  def warning(message)
    puts "\e[0;31;49m[WARN] #{message}\e[0m"
  end

  def log(message)
    puts "\e[0;32;49m[LOG] #{message}\e[0m"
  end

end
