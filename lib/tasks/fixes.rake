desc "This namespace is for ad-hoc fixes so that we don't misuse migrations."
namespace :fixes do

  desc "Prunes all but last usage limits with the same plan_id, metric_id and period"
  task :dup_usage_limits => :environment do

    ThreeScale::Rake::RemoveDupUsageLimits.run!(ENV['PROVIDER_ID'])
  end

  task :create_missing_service_tokens => :environment do
    Service.find_each do |service|
      provider = service.account
      if service.service_token.blank?
        puts "creating service token for service #{service.id} (#{service.name}) of provider #{provider.id} (#{provider.name})"
        event = Services::ServiceCreatedEvent.create(service, nil)
        Rails.application.config.event_store.publish_event(event)
      else
        puts "token exists for service #{service.id} (#{service.name}) of provider #{provider.id} (#{provider.name})"
      end
    end
  end

  desc "updates impersonation_admin email address"
  task :update_impersonation_admin_email => :environment do
    impersonation_admin_config   = ThreeScale.config.impersonation_admin
    impersonation_admin_username = impersonation_admin_config['username']
    impersonation_admin_domain   = impersonation_admin_config['domain']

    users= User.where(email: "#{impersonation_admin_username}@#{impersonation_admin_domain}")
    users.each do | user |
      provider= user.account

      unless provider
        # found some users without a provider account. this is a good time to kill them!
        puts "==> failed to acquire account of user #{user.inspect} [destroy]"
        user.destroy
        next
      end

      print "==> changing email address of impersonation_admin user of provider: #{provider.org_name}(#{provider.id}) "


      if user.update_attribute(:email, "#{impersonation_admin_username}+#{provider.self_domain}@#{impersonation_admin_domain}")
        print "[ok]\n"
      else
        print "[skip]\n"
        puts "validation #{user.errors.full_messages.join(", ")}"
      end
    end
  end

  desc "deletes dangling sections that belong to deleted providers"
  task :remove_dangling_cms_sections => :environment do
    dangling_sections = CMS::Section.select{ |sec| sec.provider == nil and sec.pages.empty? }
    puts "dangling_sections: #{dangling_sections.size}"
    dangling_sections.each &:delete
    puts "dangling sections after: ", CMS::Section.select{ |sec| sec.provider == nil and sec.pages.empty?}.size
  end

  desc "Normalize invalid paths in cms"
  task :cms_paths => :environment do
    models = [ CMS::Page, CMS::File, CMS::Section, CMS::Redirect ]
    models.each do |model|
      model.find_each do |record|
        unless record.valid?
          name = "#{record.class}(id: #{record.id})"
          changes = record.changes
          if record.save
            puts "Fixed #{name} => #{changes}"
          else
            puts "Not Fixed #{name} => #{changes}"
          end
        end
      end
    end
  end

  desc "Move S3 assets to proper folder (utc date)"
  task :s3_timezones => :environment do
    CMS::File.all.each do |file|
      utc_path = file.attachment.path

      def file.date
        attachment_updated_at.in_time_zone(provider.timezone).to_date
      end

      old_path = file.attachment.path

      if old_path != utc_path
        s3 = file.attachment.s3_object.bucket.objects[old_path]

        if s3.exists?
          s3.move_to(utc_path)
          puts "moved #{old_path} => #{utc_path}"
        else
          warn "missing #{old_path}"
        end

      end

    end
  end

  desc "Updates database.yml to mysql2 driver"
  task :database_yml do
    `sed -i -e 's/adapter\:\ mysql$/adapter\:\ mysql2/g' config/database.yml`
  end

  desc "Regenerate logo thumbnails"
  task :regenerate_logo_thumbnails => :environment do
    Profile.find(:all, :conditions => "logo_file_name IS NOT NULL").each do |profile|
      profile.logo.reprocess! rescue nil #this might actually fail due to missing images, ignoring
    end
  end

  desc "Checks for cinstances with zero plan_id and associats them with the Default plan"
  task :zero_plan_id => :environment do
    Cinstance.find_each do |cinstance|
      if cinstance.plan_id == 0
        cinstance.plan = cinstance.user_account.provider_account.service.application_plans.default
        cinstance.save!
        puts "Fixed Cinstance #{cinstance.id}"
      end
    end
  end

  desc "vat fields moving specific fix"
  task :vat_fields_moving => :environment do
    Account.find_each do |account|
      [ :vat_code, :fiscal_code ].each do |attr|
        if account.extra_fields[attr].present?
          puts "Adjusting #{attr} of #{account.org_name}"
          account.send("#{attr}=", account.extra_fields[attr])
          account.extra_fields[attr] = nil
          account.save!
        end
      end
    end
  end

  desc 'Migrate friendly_id to newer format with trailing 0'
  task :add_trailing_zeroes => :environment do
    Invoice.find_each do  |invoice|
      friendly_id_contents = invoice.friendly_id.split('-')
      next unless friendly_id_contents.all?{ |a| a =~ /^\d+$/ }
      friendly_id_contents[2] = '%08d' % friendly_id_contents[2]
      invoice.friendly_id = friendly_id_contents.join('-')
      invoice.save
    end
  end

  desc "Regenerate friendly_ids for ALL Invoices"
  task :regenerate_invoices_friendly_id => :environment do
    Invoice.find_each do | invoice |
      Rails.logger.info "regenerate_friendly_id: zeroing invoice #{invoice.id} from #{invoice.friendly_id} to 0000-00-00000000"
      Rails.logger.info "regenerate_friendly_id: undo with: i = Invoice.find(#{invoice.id}); i.friendly_id = '#{invoice.friendly_id}'; i.save"

      invoice.friendly_id = "0000-00-00000000"
      invoice.save!
    end

    Invoice.find_each do | invoice |
      set_invoice_friendly_id(invoice)
      invoice.save!
    end
  end

  #same implementation than private method Invoice#set_friendly_id
  def set_invoice_friendly_id(invoice, step = 1)
    Invoice.transaction do
      last_of_period = Invoice.by_provider(invoice.provider_account).find(:first,
                                                                          :conditions => { :period => invoice.period },
                                                                          :order => "friendly_id DESC")
      order = if last_of_period
                last_of_period.friendly_id.split('-').last
              else
                0
              end
      Rails.logger.info "regenerate_friendly_id: setting friendly_id of invoice #{invoice.id} to #{invoice.period.to_param}-#{'%08d' % (order.to_i + step)}"
      invoice.friendly_id = "#{invoice.period.to_param}-#{'%08d' % (order.to_i + step)}"
    end
  end


  desc "Make all metrics without usage_limits be hidden"
  task :hide_limitless_metrics => :environment do
    ApplicationPlan.find_each do |plan|
      plan.metrics_without_limits.each do | metric |
        if metric.visible_in_plan? plan
          puts "hiding metric:#{metric.name} in plan #{plan.name}"
          metric.toggle_visible_for_plan plan
        end
      end
    end
  end

  desc "Removes invalid mail dispatch rules that point to nowhere"
  task :remove_invalid_mail_dispatch_rules => :environment do
    MailDispatchRule.connection.execute "DELETE FROM mail_dispatch_rules WHERE not exists (SELECT * FROM system_operations WHERE id = mail_dispatch_rules.system_operation_id)"
  end

  desc "fix blog portlets"
  task :fix_blog_portlets => :environment do
    BlogPostPortlet.all.each do |bp|
      a = bp.portlet_attributes.detect{|a| a.name == "template"}
      a.update_attribute :value, BlogPostPortlet.default_template
    end

    BlogPostsPortlet.all.each do |b|
      b.template = BlogPostsPortlet.default_template
      b.save!
    end
  end


  desc "add missing variable cost of May 2012 to all providers"
  task :fire => :environment do
    may = Month.new(Date.today - 1.month)
    june = Month.new(Date.today)

    Cinstance.find_each do |c|
      cost = c.calculate_variable_cost(may).last.values.inject(0) { |sum,n| n+sum }

      if cost > 0
        puts "#{c.account.provider_account.id}/#{c.account.provider_account.name} for #{c.account.id}/#{c.account.name}, #{cost.to_f}"
        buyer = c.account
        provider = buyer.provider_account
        invoice = nil

        if provider.billing_strategy.is_a?(Finance::PrepaidBillingStrategy)
          invoices = buyer.invoices.by_month_number(6).finalized
          raise 'too many invoices' if invoices.count > 1

          if invoices.empty?
            invoice =provider.billing_strategy.create_invoice!(:buyer_account => buyer, :period => june, :finalized_at => Date.new(2012,6,1))
          else
            invoice = invoices.first
            invoice.state = 'open'
            invoice.save!
            invoice.reload
          end

        elsif provider.billing_strategy.is_a?(Finance::PostpaidBillingStrategy)
          invoices = buyer.invoices.by_month_number(5).finalized
          raise 'too many invoices' if invoices.count > 1

          if invoices.empty?
            invoice = provider.billing_strategy.create_invoice!(:buyer_account => buyer, :period => may, :finalized_at => Date.new(2012,6,1))
          else
            invoice = invoices.first
            invoice.state = 'open'
            invoice.save!
            invoice.reload
          end
        else
          raise 'AAAAA!!!'
        end

        c.send :bill_variable_fee_for, may, invoice
        invoice.save!

        invoice.state = 'finalized'
        invoice.save!
      end
    end
  end

  task :missing_github_authentication do
    Provider.all.find_each(batch_size: 100) do |provider|
      if SimpleLayout.new(provider).import_authentication
        puts "created published GitHub provider for #{provider.org_name} (#{provider.id})"
      else
        puts "#{provider.org_name} (#{provider.id}) already has github provider"
      end
    end
  end

  desc 'Fixing Account contracts states'
  task :account_contracts_states => :environment do
    # keys are for account, values are for account contract
    provider_states_transitions = {
      'created' => 'pending',
      'pending' => 'pending',
      'approved' => 'live',
      'rejected' => 'pending',
      'suspended' => 'suspended'
    }

    # This case should not happen but still adding a guard
    buyer_states_transitions = provider_states_transitions.merge('suspended' => 'pending')

    logger = ActiveSupport::Logger.new('log/fixes_account_contract_states.log')

    exec_batch = lambda do |label, scope, states|
      total = scope.count
      counter = 0
      scope.find_in_batches do |records|
        logger.info "Fixing account contracts of #{label} #{[counter += 1000, total].min} / #{total}"
        records.each do |account|
          account.bought_account_contract&.update_column(:state, states.fetch(account.state))
        end
      end
    end

    exec_batch.call(:providers, Account.providers, provider_states_transitions)
    exec_batch.call(:developers, Account.buyers, buyer_states_transitions)
  end
end
