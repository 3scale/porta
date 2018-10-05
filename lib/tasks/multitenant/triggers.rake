# frozen_string_literal: true

require 'system/database'

namespace :multitenant do

  task :test => :environment do
    # ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])
    ActiveRecord::Base.establish_connection(:test)
  end

  desc "Loads triggers to test database"
  task 'test:triggers' => ['multitenant:test', 'multitenant:triggers']

  triggers = []

  namespace :triggers do
    task :oracle do
      triggers << System::Database::OracleTrigger.new('accounts', <<~SQL)
        IF :new.buyer = 1 THEN
          :new.tenant_id := :new.provider_account_id;
        END IF;
      SQL

      triggers << System::Database::OracleTrigger.new('audits', <<~SQL)
        IF :new.provider_id <> master_id THEN
          :new.tenant_id := :new.provider_id;
        END IF;
      SQL

      triggers << System::Database::OracleTrigger.new('alerts', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM accounts WHERE id = :new.account_id AND master <> 1;
      SQL

      triggers << System::Database::OracleTrigger.new('api_docs_services', <<~SQL)
        IF :new.account_id <> master_id THEN
          :new.tenant_id := :new.account_id;
        END IF;
      SQL

      triggers << System::Database::OracleTrigger.new('application_keys', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM cinstances WHERE id = :new.application_id AND tenant_id <> master_id;
      SQL

      triggers << System::Database::OracleTrigger.new('billing_strategies', <<~SQL)
        IF :new.account_id <> master_id THEN
          :new.tenant_id := :new.account_id;
        END IF;
      SQL

      triggers << System::Database::OracleTrigger.new('cinstances', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM plans WHERE id = :new.plan_id AND tenant_id <> master_id;
      SQL

      triggers << System::Database::OracleTrigger.new('configuration_values', <<~SQL)
        IF :new.configurable_type = 'Account' AND :new.configurable_id <> master_id THEN
          :new.tenant_id := :new.configurable_id;
        ELSIF :new.configurable_type = 'Service' THEN
           SELECT tenant_id INTO :new.tenant_id FROM services WHERE id = :new.configurable_id AND tenant_id <> master_id;
        END IF;
      SQL

      triggers << System::Database::OracleTrigger.new('end_user_plans', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM services WHERE id = :new.service_id AND tenant_id <> master_id;
      SQL

      triggers << System::Database::OracleTrigger.new('features', <<~SQL)
        IF :new.featurable_type = 'Account' AND :new.featurable_id <> master_id THEN
          :new.tenant_id := :new.featurable_id;
        ELSIF :new.featurable_type = 'Service' THEN
          SELECT tenant_id INTO :new.tenant_id FROM services WHERE id = :new.featurable_id AND tenant_id <> master_id;
        END IF;
      SQL

      triggers << System::Database::OracleTrigger.new('features_plans', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM features WHERE id = :new.feature_id AND tenant_id <> master_id;
      SQL

      triggers << System::Database::OracleTrigger.new('fields_definitions', <<~SQL)
        IF :new.account_id <> master_id THEN
          :new.tenant_id := :new.account_id;
        END IF;
      SQL

      triggers << System::Database::OracleTrigger.new('forums', <<~SQL)
        IF :new.account_id <> master_id THEN
          :new.tenant_id := :new.account_id;
        END IF;
      SQL

      triggers << System::Database::OracleTrigger.new('invitations', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM accounts WHERE id = :new.account_id AND tenant_id <> master_id;
      SQL

      invoices_trigger = <<-SQL
        IF :NEW.provider_account_id <> master_id THEN
          :NEW.tenant_id := :NEW.provider_account_id;
        END IF;

        IF :NEW.friendly_id IS NOT NULL AND :NEW.friendly_id <> 'fix' THEN
          /* Subject to race condition, so better not to create invoices in parallel passing client-chosen friendly IDs */

          SELECT numbering_period INTO v_numbering_period
                                   FROM billing_strategies
                                   WHERE account_id = :NEW.provider_account_id
                                   AND ROWNUM = 1;

          IF v_numbering_period = 'monthly' THEN
            v_invoice_prefix_format := 'YYYY-MM';
          ELSE
            v_invoice_prefix_format := 'YYYY';
          END IF;

          v_invoice_prefix := TO_CHAR(:NEW.period, v_invoice_prefix_format);

          SELECT id, invoice_count
                  INTO v_invoice_counter_id, v_invoice_count
                  FROM invoice_counters
                  WHERE provider_account_id = :NEW.provider_account_id AND invoice_prefix = v_invoice_prefix
                  AND ROWNUM = 1
                  FOR UPDATE;

          v_chosen_sufix := COALESCE(TO_NUMBER(SUBSTR(:NEW.friendly_id, -8)), 0);
          v_invoice_count := GREATEST(COALESCE(v_invoice_count, 0), v_chosen_sufix);

          UPDATE invoice_counters
          SET invoice_count = v_invoice_count, updated_at = :NEW.updated_at
          WHERE id = v_invoice_counter_id;
        END IF;
      SQL

      triggers << System::Database::OracleTriggerWithVariables.new('invoices', invoices_trigger, <<~SQL)
        v_numbering_period varchar(255);
        v_invoice_prefix_format varchar(255);
        v_invoice_prefix varchar(255);
        v_invoice_count NUMBER;
        v_chosen_sufix NUMBER;
        v_invoice_counter_id NUMBER;
      SQL

      triggers << System::Database::OracleTrigger.new('line_items', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM invoices WHERE id = :new.invoice_id AND tenant_id <> master_id;
      SQL

      triggers << System::Database::OracleTrigger.new('mail_dispatch_rules', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM accounts WHERE id = :new.account_id AND tenant_id <> master_id;
      SQL

      triggers << System::Database::OracleTrigger.new('message_recipients', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM messages WHERE id = :new.message_id AND tenant_id <> master_id;
      SQL

      # FIXME: this one is actually weird, the relation is polymorphic but the type is *always* Account

      triggers << System::Database::OracleTrigger.new('messages', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM accounts WHERE id = :new.sender_id AND tenant_id <> master_id;
      SQL

      triggers << System::Database::OracleTrigger.new('metrics', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM services WHERE id = :new.service_id AND tenant_id <> master_id;
      SQL

      triggers << System::Database::OracleTrigger.new('moderatorships', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM forums WHERE id = :new.forum_id AND tenant_id <> master_id;
      SQL

      triggers << System::Database::OracleTrigger.new('payment_transactions', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM invoices WHERE id = :new.invoice_id AND tenant_id <> master_id;
      SQL


      triggers << System::Database::OracleTrigger.new('plan_metrics', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM plans WHERE id = :new.plan_id AND tenant_id <> master_id;
      SQL

      triggers << System::Database::OracleTrigger.new('plans', <<~SQL)
        IF :new.type = 'AccountPlan' AND :new.issuer_id <> master_id THEN
          :new.tenant_id := :new.issuer_id;
        ELSIF :new.type = 'ApplicationPlan' OR :new.type = 'ServicePlan' THEN
          SELECT tenant_id INTO :new.tenant_id FROM services WHERE id = :new.issuer_id AND tenant_id <> master_id;
        END IF;
      SQL

      triggers << System::Database::OracleTrigger.new('posts', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM forums WHERE id = :new.forum_id AND tenant_id <> master_id;
      SQL

      triggers << System::Database::OracleTrigger.new('pricing_rules', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM plans WHERE id = :new.plan_id AND tenant_id <> master_id;
      SQL


      triggers << System::Database::OracleTrigger.new('profiles', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM accounts WHERE id = :new.account_id AND tenant_id <> master_id;
      SQL


      triggers << System::Database::OracleTrigger.new('referrer_filters', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM cinstances WHERE id = :new.application_id AND tenant_id <> master_id;
      SQL

      triggers << System::Database::OracleTrigger.new('services', <<~SQL)
        IF :new.account_id <> master_id THEN
            :new.tenant_id := :new.account_id;
        END IF;
      SQL

      triggers << System::Database::OracleTrigger.new('settings', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM accounts WHERE id = :new.account_id AND tenant_id <> master_id;
      SQL

      triggers << System::Database::OracleTrigger.new('authentication_providers', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM accounts WHERE id = :new.account_id AND tenant_id <> master_id;
      SQL

      triggers << System::Database::OracleTrigger.new('slugs', <<~SQL)
        IF :new.sluggable_type = 'Profile' THEN
          SELECT tenant_id INTO :new.tenant_id FROM profiles WHERE id = :new.sluggable_id AND tenant_id <> master_id;
        ELSIF :new.sluggable_type = 'Service' THEN
          SELECT tenant_id INTO :new.tenant_id FROM services WHERE id = :new.sluggable_id AND tenant_id <> master_id;
        END IF;
      SQL

      triggers << System::Database::OracleTrigger.new('topic_categories', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM forums WHERE id = :new.forum_id AND tenant_id <> master_id;
      SQL

      triggers << System::Database::OracleTrigger.new('topics', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM forums WHERE id = :new.forum_id AND tenant_id <> master_id;
      SQL


      triggers << System::Database::OracleTrigger.new('usage_limits', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM metrics WHERE id = :new.metric_id AND tenant_id <> master_id;
      SQL


      triggers << System::Database::OracleTrigger.new('user_topics', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM topics WHERE id = :new.topic_id AND tenant_id <> master_id;
      SQL

      triggers << System::Database::OracleTrigger.new('users', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM accounts WHERE id = :new.account_id AND tenant_id <> master_id;
      SQL

      triggers << System::Database::OracleTrigger.new('web_hooks', <<~SQL)
        IF :new.account_id <> master_id THEN
            :new.tenant_id := :new.account_id;
        END IF;
      SQL

      triggers << System::Database::OracleTrigger.new('categories', <<~SQL)
        IF :new.account_id <> master_id THEN
          :new.tenant_id := :new.account_id;
        END IF;
      SQL

      triggers << System::Database::OracleTrigger.new('category_types', <<~SQL)
        IF :new.account_id <> master_id THEN
          :new.tenant_id := :new.account_id;
        END IF;
      SQL

      triggers << System::Database::OracleTrigger.new('tags', <<~SQL)
        IF :new.account_id <> master_id THEN
          :new.tenant_id := :new.account_id;
        END IF;
      SQL

      triggers << System::Database::OracleTrigger.new('taggings', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM tags WHERE id = :new.tag_id AND tenant_id <> master_id;
      SQL

      triggers << System::Database::OracleTrigger.new('legal_terms', <<~SQL)
        IF :new.account_id <> master_id THEN
          :new.tenant_id := :new.account_id;
        END IF;
      SQL

      triggers << System::Database::OracleTrigger.new('legal_term_versions', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM legal_terms WHERE id = :new.legal_term_id AND tenant_id <> master_id;
      SQL

      triggers << System::Database::OracleTrigger.new('legal_term_acceptances', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM legal_terms WHERE id = :new.legal_term_id AND tenant_id <> master_id;
      SQL

      triggers << System::Database::OracleTrigger.new('legal_term_bindings', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM legal_terms WHERE id = :new.legal_term_id AND tenant_id <> master_id;
      SQL

      triggers << System::Database::OracleTrigger.new('member_permissions', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM users WHERE id = :new.user_id;
      SQL

      triggers << System::Database::OracleTrigger.new('cms_sections', <<~SQL)
        IF :new.provider_id <> master_id THEN
          :new.tenant_id := :new.provider_id;
        END IF;
      SQL

      triggers << System::Database::OracleTrigger.new('cms_permissions', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM cms_groups WHERE id = :new.group_id;
      SQL

      triggers << System::Database::OracleTrigger.new('cms_groups', <<~SQL)
        IF :new.provider_id <> master_id THEN
          :new.tenant_id := :new.provider_id;
        END IF;
      SQL

      # due to table renaming you might have this older trigger on that table

      triggers << System::Database::OracleTrigger.new('cms_group_sections', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM cms_groups WHERE id = :new.group_id;
      SQL

      triggers << System::Database::OracleTrigger.new('cms_templates', <<~SQL)
        IF (master_id IS NULL OR :new.provider_id <> master_id) THEN
          :new.tenant_id := :new.provider_id;
        END IF;
      SQL

      triggers << System::Database::OracleTrigger.new('cms_templates_versions', <<~SQL)
        IF :new.provider_id <> master_id THEN
          :new.tenant_id := :new.provider_id;
        END IF;
      SQL

      triggers << System::Database::OracleTrigger.new('cms_files', <<~SQL)
        IF :new.provider_id <> master_id THEN
          :new.tenant_id := :new.provider_id;
        END IF;
      SQL

      triggers << System::Database::OracleTrigger.new('log_entries', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM accounts WHERE id = :new.provider_id AND master <> 1;
      SQL

      triggers << System::Database::OracleTrigger.new('cms_redirects', <<~SQL)
        IF :new.provider_id <> master_id THEN
          :new.tenant_id := :new.provider_id;
        END IF;
      SQL

      triggers << System::Database::OracleTrigger.new('proxy_logs', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM accounts WHERE id = :new.provider_id AND master <> 1;
      SQL

      triggers << System::Database::OracleTrigger.new('proxies', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM services WHERE id = :new.service_id AND tenant_id <> master_id;
      SQL

      triggers << System::Database::OracleTrigger.new('proxy_rules', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM proxies WHERE id = :new.proxy_id AND tenant_id <> master_id;
      SQL

      triggers << System::Database::OracleTrigger.new('provider_constraints', <<~SQL)
        :new.tenant_id := :new.provider_id;
      SQL

      triggers << System::Database::OracleTrigger.new('proxy_configs', <<~SQL)
        SELECT tenant_id INTO :new.tenant_id FROM proxies WHERE id = :new.proxy_id AND tenant_id <> master_id;
      SQL

      triggers << System::Database::OracleTrigger.new('access_tokens', <<-SQL)
        SELECT tenant_id INTO :new.tenant_id FROM users WHERE id = :new.owner_id AND tenant_id <> master_id;
      SQL

      triggers << System::Database::OracleTrigger.new('event_store_events', <<-SQL)
        :new.tenant_id := :new.provider_id;
      SQL

      triggers << System::Database::OracleTrigger.new('notification_preferences', <<-SQL)
        SELECT tenant_id INTO :new.tenant_id FROM users WHERE id = :new.user_id AND tenant_id <> master_id;
      SQL

      triggers << System::Database::OracleTrigger.new('go_live_states', <<-SQL)
        IF :new.account_id <> master_id THEN
          :new.tenant_id := :new.account_id;
        END IF;
      SQL

      triggers << System::Database::OracleTrigger.new('notification_preferences', <<-SQL)
        SELECT tenant_id INTO :new.tenant_id FROM users WHERE id = :new.user_id AND tenant_id <> master_id;
      SQL

      triggers << System::Database::OracleTrigger.new('onboardings', <<-SQL)
        IF :new.account_id <> master_id THEN
          :new.tenant_id := :new.account_id;
        END IF;
      SQL

      triggers << System::Database::OracleTrigger.new('payment_details', <<-SQL)
        SELECT tenant_id INTO :new.tenant_id FROM accounts WHERE id = :new.account_id AND tenant_id <> master_id;
      SQL

      triggers << System::Database::OracleTrigger.new('payment_gateway_settings', <<-SQL)
        IF :new.account_id <> master_id THEN
          :new.tenant_id := :new.account_id;
        END IF;
      SQL

      triggers << System::Database::OracleTrigger.new('service_tokens', <<-SQL)
        SELECT tenant_id INTO :new.tenant_id FROM services WHERE id = :new.service_id AND tenant_id <> master_id;
      SQL

      triggers << System::Database::OracleTrigger.new('sso_authorizations', <<-SQL)
        SELECT tenant_id INTO :new.tenant_id FROM users WHERE id = :new.user_id AND tenant_id <> master_id;
      SQL
    end

    task :mysql do
      triggers << System::Database::MySQLTrigger.new('accounts', <<~SQL)
        IF NEW.buyer THEN
          SET NEW.tenant_id = NEW.provider_account_id;
        END IF;
      SQL

      triggers << System::Database::MySQLTrigger.new('audits', <<~SQL)
        IF NEW.provider_id <> master_id THEN
          SET NEW.tenant_id = NEW.provider_id;
        END IF;
      SQL

      triggers << System::Database::MySQLTrigger.new('alerts', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM accounts WHERE id = NEW.account_id AND NOT master);
      SQL

      triggers << System::Database::MySQLTrigger.new('api_docs_services', <<~SQL)
        IF NEW.account_id <> master_id THEN
          SET NEW.tenant_id = NEW.account_id;
        END IF;
      SQL

      triggers << System::Database::MySQLTrigger.new('application_keys', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM cinstances WHERE id = NEW.application_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('billing_strategies', <<~SQL)
        IF NEW.account_id <> master_id THEN
          SET NEW.tenant_id = NEW.account_id;
        END IF;
      SQL

      triggers << System::Database::MySQLTrigger.new('cinstances', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM plans WHERE id = NEW.plan_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('configuration_values', <<~SQL)
        IF NEW.configurable_type = 'Account' AND NEW.configurable_id <> master_id THEN
          SET NEW.tenant_id = NEW.configurable_id;
        ELSEIF NEW.configurable_type = 'Service' THEN
          SET NEW.tenant_id = (SELECT tenant_id FROM services WHERE id = NEW.configurable_id AND tenant_id <> master_id);
        END IF;
      SQL

      triggers << System::Database::MySQLTrigger.new('end_user_plans', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM services WHERE id = NEW.service_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('features', <<~SQL)
        IF NEW.featurable_type = 'Account' AND NEW.featurable_id <> master_id THEN
          SET NEW.tenant_id = NEW.featurable_id;
        ELSEIF NEW.featurable_type = 'Service' THEN
          SET NEW.tenant_id = (SELECT tenant_id FROM services WHERE id = NEW.featurable_id AND tenant_id <> master_id);
        END IF;
      SQL

      triggers << System::Database::MySQLTrigger.new('features_plans', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM features WHERE id = NEW.feature_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('fields_definitions', <<~SQL)
        IF NEW.account_id <> master_id THEN
          SET NEW.tenant_id = NEW.account_id;
        END IF;
      SQL

      triggers << System::Database::MySQLTrigger.new('forums', <<~SQL)
        IF NEW.account_id <> master_id THEN
          SET NEW.tenant_id = NEW.account_id;
        END IF;
      SQL

      triggers << System::Database::MySQLTrigger.new('invitations', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM accounts WHERE id = NEW.account_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('invoices', <<~SQL)
        IF NEW.provider_account_id <> master_id THEN
          SET NEW.tenant_id = NEW.provider_account_id;
        END IF;

        IF NEW.friendly_id IS NOT NULL AND NEW.friendly_id <> 'fix' THEN
          /* Subject to race condition, so better not to create invoices in parallel passing client-chosen friendly IDs */

          SET @numbering_period = (SELECT numbering_period
                                   FROM billing_strategies
                                   WHERE account_id = NEW.provider_account_id
                                   LIMIT 1);

          IF @numbering_period = 'monthly' THEN
            SET @invoice_prefix_format = "%Y-%m";
          ELSE
            SET @invoice_prefix_format = "%Y";
          END IF;

          SET @invoice_prefix = DATE_FORMAT(NEW.period, @invoice_prefix_format);

          SELECT id, invoice_count
                  INTO @invoice_counter_id, @invoice_count
                  FROM invoice_counters
                  WHERE provider_account_id = NEW.provider_account_id AND invoice_prefix = @invoice_prefix
                  LIMIT 1
                  FOR UPDATE;

          SET @chosen_sufix = COALESCE(SUBSTRING_INDEX(NEW.friendly_id, '-', -1), 0) * 1;
          SET @invoice_count = GREATEST(COALESCE(@invoice_count, 0), @chosen_sufix);

          UPDATE invoice_counters
          SET invoice_count = @invoice_count, updated_at = NEW.updated_at
          WHERE id = @invoice_counter_id;
        END IF;
      SQL

      triggers << System::Database::MySQLTrigger.new('line_items', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM invoices WHERE id = NEW.invoice_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('mail_dispatch_rules', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM accounts WHERE id = NEW.account_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('message_recipients', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM messages WHERE id = NEW.message_id AND tenant_id <> master_id);
      SQL

      # FIXME: this one is actually weird, the relation is polymorphic but the type is *always* Account

      triggers << System::Database::MySQLTrigger.new('messages', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM accounts WHERE id = NEW.sender_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('metrics', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM services WHERE id = NEW.service_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('moderatorships', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM forums WHERE id = NEW.forum_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('payment_transactions', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM invoices WHERE id = NEW.invoice_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('plan_metrics', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM plans WHERE id = NEW.plan_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('plans', <<~SQL)
        IF NEW.type = 'AccountPlan' AND NEW.issuer_id <> master_id THEN
          SET NEW.tenant_id = NEW.issuer_id;
        ELSEIF NEW.type = 'ApplicationPlan' OR NEW.type = 'ServicePlan' THEN
          SET NEW.tenant_id = (SELECT tenant_id FROM services WHERE id = NEW.issuer_id AND tenant_id <> master_id);
        END IF;
      SQL

      triggers << System::Database::MySQLTrigger.new('posts', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM forums WHERE id = NEW.forum_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('pricing_rules', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM plans WHERE id = NEW.plan_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('profiles', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM accounts WHERE id = NEW.account_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('referrer_filters', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM cinstances WHERE id = NEW.application_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('services', <<~SQL)
        IF NEW.account_id <> master_id THEN
            SET NEW.tenant_id = NEW.account_id;
        END IF;
      SQL

      triggers << System::Database::MySQLTrigger.new('settings', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM accounts WHERE id = NEW.account_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('authentication_providers', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM accounts WHERE id = NEW.account_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('slugs', <<~SQL)
        IF NEW.sluggable_type = 'Profile' THEN
          SET NEW.tenant_id = (SELECT tenant_id FROM profiles WHERE id = NEW.sluggable_id AND tenant_id <> master_id);
        ELSEIF NEW.sluggable_type = 'Service' THEN
          SET NEW.tenant_id = (SELECT tenant_id FROM services WHERE id = NEW.sluggable_id AND tenant_id <> master_id);
        END IF;
      SQL

      triggers << System::Database::MySQLTrigger.new('topic_categories', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM forums WHERE id = NEW.forum_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('topics', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM forums WHERE id = NEW.forum_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('usage_limits', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM metrics WHERE id = NEW.metric_id AND tenant_id <> master_id);
      SQL


      triggers << System::Database::MySQLTrigger.new('user_topics', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM topics WHERE id = NEW.topic_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('users', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM accounts WHERE id = NEW.account_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('web_hooks', <<~SQL)
        IF NEW.account_id <> master_id THEN
            SET NEW.tenant_id = NEW.account_id;
        END IF;
      SQL

      triggers << System::Database::MySQLTrigger.new('categories', <<~SQL)
        IF NEW.account_id <> master_id THEN
          SET NEW.tenant_id = NEW.account_id;
        END IF;
      SQL

      triggers << System::Database::MySQLTrigger.new('category_types', <<~SQL)
        IF NEW.account_id <> master_id THEN
          SET NEW.tenant_id = NEW.account_id;
        END IF;
      SQL

      triggers << System::Database::MySQLTrigger.new('tags', <<~SQL)
        IF NEW.account_id <> master_id THEN
          SET NEW.tenant_id = NEW.account_id;
        END IF;
      SQL

      triggers << System::Database::MySQLTrigger.new('taggings', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM tags WHERE id = NEW.tag_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('legal_terms', <<~SQL)
        IF NEW.account_id <> master_id THEN
          SET NEW.tenant_id = NEW.account_id;
        END IF;
      SQL

      triggers << System::Database::MySQLTrigger.new('legal_term_versions', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM legal_terms WHERE id = NEW.legal_term_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('legal_term_acceptances', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM legal_terms WHERE id = NEW.legal_term_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('legal_term_bindings', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM legal_terms WHERE id = NEW.legal_term_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('member_permissions', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM users WHERE id = NEW.user_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('cms_sections', <<~SQL)
        IF NEW.provider_id <> master_id THEN
          SET NEW.tenant_id = NEW.provider_id;
        END IF;
      SQL

      triggers << System::Database::MySQLTrigger.new('cms_permissions', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM cms_groups WHERE id = NEW.group_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('cms_groups', <<~SQL)
        IF NEW.provider_id <> master_id THEN
          SET NEW.tenant_id = NEW.provider_id;
        END IF;
      SQL

      # due to table renaming you might have this older trigger on that table
      triggers << System::Database::MySQLTrigger.new('cms_group_sections', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM cms_groups WHERE id = NEW.group_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('cms_templates', <<~SQL)
        IF (master_id IS NULL OR NEW.provider_id <> master_id) THEN
          SET NEW.tenant_id = NEW.provider_id;
        END IF;
      SQL

      triggers << System::Database::MySQLTrigger.new('cms_templates_versions', <<~SQL)
        IF NEW.provider_id <> master_id THEN
          SET NEW.tenant_id = NEW.provider_id;
        END IF;
      SQL

      triggers << System::Database::MySQLTrigger.new('cms_files', <<~SQL)
        IF NEW.provider_id <> master_id THEN
          SET NEW.tenant_id = NEW.provider_id;
        END IF;
      SQL

      triggers << System::Database::MySQLTrigger.new('log_entries', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM accounts WHERE id = NEW.provider_id AND NOT master);
      SQL

      triggers << System::Database::MySQLTrigger.new('cms_redirects', <<~SQL)
        IF NEW.provider_id <> master_id THEN
          SET NEW.tenant_id = NEW.provider_id;
        END IF;
      SQL

      triggers << System::Database::MySQLTrigger.new('proxy_logs', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM accounts WHERE id = NEW.provider_id AND NOT master);
      SQL

      triggers << System::Database::MySQLTrigger.new('proxies', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM services WHERE id = NEW.service_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('proxy_rules', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM proxies WHERE id = NEW.proxy_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('provider_constraints', <<~SQL)
        SET NEW.tenant_id = NEW.provider_id;
      SQL

      triggers << System::Database::MySQLTrigger.new('proxy_configs', <<~SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM proxies WHERE id = NEW.proxy_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('access_tokens', <<-SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM users WHERE id = NEW.owner_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('event_store_events', <<-SQL)
        SET NEW.tenant_id = NEW.provider_id;
      SQL

      triggers << System::Database::MySQLTrigger.new('go_live_states', <<-SQL)
        IF NEW.account_id <> master_id THEN
          SET NEW.tenant_id = NEW.account_id;
        END IF;
      SQL

      triggers << System::Database::MySQLTrigger.new('notification_preferences', <<-SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM users WHERE id = NEW.user_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('onboardings', <<-SQL)
        IF NEW.account_id <> master_id THEN
          SET NEW.tenant_id = NEW.account_id;
        END IF;
      SQL

      triggers << System::Database::MySQLTrigger.new('payment_details', <<-SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM accounts WHERE id = NEW.account_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('payment_gateway_settings', <<-SQL)
        IF NEW.account_id <> master_id THEN
          SET NEW.tenant_id = NEW.account_id;
        END IF;
      SQL

      triggers << System::Database::MySQLTrigger.new('service_tokens', <<-SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM services WHERE id = NEW.service_id AND tenant_id <> master_id);
      SQL

      triggers << System::Database::MySQLTrigger.new('sso_authorizations', <<-SQL)
        SET NEW.tenant_id = (SELECT tenant_id FROM users WHERE id = NEW.user_id AND tenant_id <> master_id);
      SQL
    end

    task :load_triggers do
      if System::Database.oracle?
        Rake::Task['multitenant:triggers:oracle'].invoke
      elsif System::Database.mysql?
        Rake::Task['multitenant:triggers:mysql'].invoke
      else
        raise 'unsupported database triggers'
      end
    end

    task :create => %I[environment load_triggers] do
      triggers.each do |t|
        ActiveRecord::Base.connection.execute(t.create)
      end
    end

    task :drop => %I[environment load_triggers] do
      triggers.each do |t|
        ActiveRecord::Base.connection.execute(t.drop)
      end
    end
  end

  desc 'Recreates the DB triggers (delete+create)'
  task :triggers => %I[environment triggers:load_triggers] do
    puts "Recreating trigger, see log/#{Rails.env}.log"
    triggers.each do |t|
      t.recreate.each do |command|
        ActiveRecord::Base.connection.execute(command)
      end
    end
    puts "Recreated #{triggers.size} triggers"
  end

  desc 'Sets the tenant id on all relevant tables'
  task :set_tenant_id => :environment do

    MASTER_ID = Account.master.id

    Account.update_all "tenant_id = provider_account_id WHERE provider <> 1 AND (NOT master OR master IS NULL)"
    Account.update_all "tenant_id = id WHERE provider = 1"
    Alert.update_all "tenant_id = (SELECT tenant_id FROM accounts WHERE id = alerts.account_id AND tenant_id <> #{MASTER_ID})"
    ApiDocs::Service.update_all "tenant_id = account_id WHERE account_id <> #{MASTER_ID}"
    ApplicationKey.update_all "tenant_id = (SELECT tenant_id FROM cinstances WHERE id = application_keys.application_id AND tenant_id <> #{MASTER_ID})"
    Finance::BillingStrategy.update_all "tenant_id = account_id WHERE account_id <> #{MASTER_ID}"
    FieldsDefinition.update_all "tenant_id = account_id WHERE account_id <> #{MASTER_ID}"
    Forum.update_all "tenant_id = account_id WHERE account_id <> #{MASTER_ID}"
    Invoice.update_all "tenant_id = provider_account_id WHERE provider_account_id <> #{MASTER_ID}"
    LineItem.update_all "tenant_id = (SELECT tenant_id FROM invoices WHERE id = line_items.invoice_id AND tenant_id <> #{MASTER_ID})"
    Service.update_all "tenant_id = account_id WHERE account_id <> #{MASTER_ID}"
    Settings.update_all "tenant_id = (SELECT tenant_id FROM accounts WHERE id = settings.account_id AND tenant_id <> #{MASTER_ID})"
    WebHook.update_all "tenant_id = account_id WHERE account_id <> #{MASTER_ID}"
    EndUserPlan.update_all "tenant_id = (SELECT tenant_id FROM services WHERE id = end_user_plans.service_id AND tenant_id <> #{MASTER_ID})"
    Invitation.update_all "tenant_id = (SELECT tenant_id FROM accounts WHERE id = invitations.account_id AND tenant_id <> #{MASTER_ID})"
    MailDispatchRule.update_all "tenant_id = (SELECT tenant_id FROM accounts WHERE id = mail_dispatch_rules.account_id AND tenant_id <> #{MASTER_ID})"
    Message.update_all "tenant_id = (SELECT tenant_id FROM accounts WHERE id = messages.sender_id AND tenant_id <> #{MASTER_ID})"
    MessageRecipient.update_all "tenant_id = (SELECT tenant_id FROM messages WHERE id = message_recipients.message_id AND tenant_id <> #{MASTER_ID})"
    Metric.update_all "tenant_id = (SELECT tenant_id FROM services WHERE id = metrics.service_id AND tenant_id <> #{MASTER_ID})"
    PaymentTransaction.update_all "tenant_id = (SELECT tenant_id FROM invoices WHERE id = payment_transactions.invoice_id AND tenant_id <> #{MASTER_ID})"
    Moderatorship.update_all "tenant_id = (SELECT tenant_id FROM forums WHERE id = moderatorships.forum_id AND tenant_id <> #{MASTER_ID})"
    Post.update_all "tenant_id = (SELECT tenant_id FROM forums WHERE id = posts.forum_id AND tenant_id <> #{MASTER_ID})"
    Profile.update_all "tenant_id = (SELECT tenant_id FROM accounts WHERE id = profiles.account_id AND tenant_id <> #{MASTER_ID})"
    ReferrerFilter.update_all "tenant_id = (SELECT tenant_id FROM cinstances WHERE id = referrer_filters.application_id AND tenant_id <> #{MASTER_ID})"
    TopicCategory.update_all "tenant_id = (SELECT tenant_id FROM forums WHERE id = topic_categories.forum_id AND tenant_id <> #{MASTER_ID})"
    Topic.update_all "tenant_id = (SELECT tenant_id FROM forums WHERE id = topics.forum_id AND tenant_id <> #{MASTER_ID})"
    UsageLimit.update_all "tenant_id = (SELECT tenant_id FROM metrics WHERE id = usage_limits.metric_id AND tenant_id <> #{MASTER_ID})"
    UserTopic.update_all "tenant_id = (SELECT tenant_id FROM topics WHERE id = user_topics.topic_id AND tenant_id <> #{MASTER_ID})"
    User.update_all "tenant_id = (SELECT tenant_id FROM accounts WHERE id = users.account_id AND tenant_id <> #{MASTER_ID})"
    Plan.update_all "tenant_id = issuer_id WHERE type = 'AccountPlan' AND issuer_id <> #{MASTER_ID}"
    Plan.update_all "tenant_id = (SELECT tenant_id FROM services WHERE id = plans.issuer_id AND tenant_id <> #{MASTER_ID}) WHERE type <> 'AccountPlan'"
    PricingRule.update_all "tenant_id = (SELECT tenant_id FROM plans WHERE id = pricing_rules.plan_id AND tenant_id <> #{MASTER_ID})"
    PlanMetric.update_all "tenant_id = (SELECT tenant_id FROM plans WHERE id = plan_metrics.plan_id AND tenant_id <> #{MASTER_ID})"
    Contract.update_all "tenant_id = (SELECT tenant_id FROM plans WHERE id = cinstances.plan_id AND tenant_id <> #{MASTER_ID})"
    Feature.update_all "tenant_id = featurable_id WHERE featurable_type = 'Account' AND featurable_id <> #{MASTER_ID}"
    Feature.update_all "tenant_id = (SELECT tenant_id FROM services WHERE id = features.featurable_id AND tenant_id <> #{MASTER_ID}) WHERE featurable_type <> 'Account'"
    Feature.connection.execute "UPDATE features_plans SET tenant_id = (SELECT tenant_id FROM features WHERE id = features_plans.feature_id AND tenant_id <> #{MASTER_ID})"
    ActiveRecord::Base.connection.execute "UPDATE tags SET tenant_id = account_id WHERE account_id <> #{MASTER_ID}"
    ActiveRecord::Base.connection.execute "UPDATE taggings SET tenant_id = (SELECT tenant_id FROM tags WHERE id = taggings.tag_id AND tenant_id <> #{MASTER_ID})"
    CMS::Section.update_all "tenant_id = provider_id WHERE provider_id <> #{MASTER_ID}"
    CMS::Template.update_all "tenant_id = provider_id WHERE provider_id <> #{MASTER_ID}"
    CMS::Template::Version.update_all "tenant_id = provider_id WHERE provider_id <> #{MASTER_ID}"
    CMS::File.update_all "tenant_id = provider_id WHERE provider_id <> #{MASTER_ID}"
    CMS::Redirect.update_all "tenant_id = provider_id WHERE provider_id <> #{MASTER_ID}"
    CMS::Group.update_all "tenant_id = provider_id WHERE provider_id <> #{MASTER_ID}"
    CMS::Section.update_all "tenant_id = provider_id WHERE provider_id <> #{MASTER_ID}"
    CMS::Permission.update_all "tenant_id = (SELECT tenant_id FROM cms_groups WHERE cms_groups.id = group_id)"
    CMS::GroupSection.update_all "tenant_id = (SELECT tenant_id FROM cms_groups WHERE cms_groups.id = group_id)"
    MemberPermission.update_all "tenant_id = (SELECT tenant_id FROM users WHERE id = user_id)"
    LogEntry.update_all "tenant_id = provider_id WHERE provider_id <> #{MASTER_ID}"

    Proxy.update_all "tenant_id = (SELECT tenant_id FROM services WHERE id = proxies.service_id AND tenant_id <> #{MASTER_ID})"
    ProxyRule.update_all "tenant_id = (SELECT tenant_id FROM proxies WHERE id = proxy_rules.proxy_id AND tenant_id <> #{MASTER_ID})"

    AccessToken.update_all "tenant_id = (SELECT tenant_id FROM users WHERE users.id = access_tokens.owner_id AND tenant_id <> #{MASTER_ID})"
    EventStore::Event.update_all "tenant_id = provider_id WHERE provider_id <> #{MASTER_ID}"
    GoLiveState.update_all "tenant_id = account_id WHERE account_id <> #{MASTER_ID}"
    NotificationPreferences.update_all "tenant_id = (SELECT tenant_id FROM users WHERE id = user_id AND tenant_id <> #{MASTER_ID})"
    Onboarding.update_all "tenant_id = account_id WHERE account_id <> #{MASTER_ID}"
    PaymentDetail.update_all "tenant_id = (SELECT tenant_id FROM accounts WHERE id = account_id AND tenant_id <> #{MASTER_ID})"
    PaymentGatewaySetting.update_all "tenant_id = account_id WHERE account_id <> #{MASTER_ID}"
    ServiceToken.update_all "tenant_id = (SELECT tenant_id FROM services WHERE id = service_id AND tenant_id <> #{MASTER_ID})"
    SSOAuthorization.update_all "tenant_id = (SELECT tenant_id FROM users WHERE id = user_id AND tenant_id <> #{MASTER_ID})"

  end
end

Rake::Task['db:seed'].enhance(['multitenant:triggers'])
