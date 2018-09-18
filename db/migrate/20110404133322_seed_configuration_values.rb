class SeedConfigurationValues < ActiveRecord::Migration
  def self.up
    Configuration::Value.delete_all

    Account.module_eval do
      def service_preffix
        Configuration.configuration["service_preffix"]
      end
    end

    Account.providers.each do |account|
      puts "Setting configuration values for #{account.org_name}"

      account.config.class_eval do
        def []=(name, value)
          values[name] = self.class.parse(value)
        end
      end

      if account.multiple_cinstances_allowed?
        account.config[:multiple_applications] = true
      end

      if !account.backend_v2
        account.config[:backend_version] = "1"
      end

      if account.billing_strategy
        account.config[:billing_mode] = true
      end

      if account.settings.authentication_strategy != :internal
        account.config[:authentication_strategy] = account.settings.authentication_strategy
      end

      account.config.save!
    end
  ensure
    Account.module_eval do
      undef :service_preffix
    end rescue nil
  end

  def self.down
    Account.providers.each do |account|
      puts "Unsetting configuration values for #{account.org_name}"

      account.multiple_cinstances_allowed = account.config[:multiple_applications]
      account.config.delete(:multiple_applications)

      account.backend_v2 = (account.backend_version == "2")
      account.config.delete(:backend_version)

      account.settings.authentication_strategy = account.config[:authentication_strategy]
      account.config.delete(:authentication_strategy)

      account.config.save!
      account.save!
    end
  end
end
