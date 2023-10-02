# frozen_string_literal: true

require 'system/database/mysql'

System::Database::MySQL.define do
  trigger 'accounts' do
    <<~SQL
      IF NEW.buyer THEN
        SET NEW.tenant_id = NEW.provider_account_id;
      END IF;
    SQL
  end

  trigger 'audits' do
    <<~SQL
      IF NEW.provider_id <> master_id THEN
        SET NEW.tenant_id = NEW.provider_id;
      END IF;
    SQL
  end

  trigger 'alerts' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM accounts WHERE id = NEW.account_id AND (NOT master OR master is NULL));
    SQL
  end

  trigger 'api_docs_services' do
    <<~SQL
      IF NEW.account_id <> master_id THEN
        SET NEW.tenant_id = NEW.account_id;
      END IF;
    SQL
  end

  trigger 'application_keys' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM cinstances WHERE id = NEW.application_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'billing_strategies' do
    <<~SQL
      IF NEW.account_id <> master_id THEN
        SET NEW.tenant_id = NEW.account_id;
      END IF;
    SQL
  end

  trigger 'cinstances' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM plans WHERE id = NEW.plan_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'configuration_values' do
    <<~SQL
      IF NEW.configurable_type = 'Account' AND NEW.configurable_id <> master_id THEN
        SET NEW.tenant_id = NEW.configurable_id;
      ELSEIF NEW.configurable_type = 'Service' THEN
        SET NEW.tenant_id = (SELECT tenant_id FROM services WHERE id = NEW.configurable_id AND tenant_id <> master_id);
      END IF;
    SQL
  end

  trigger 'features' do
    <<~SQL
      IF NEW.featurable_type = 'Account' AND NEW.featurable_id <> master_id THEN
        SET NEW.tenant_id = NEW.featurable_id;
      ELSEIF NEW.featurable_type = 'Service' THEN
        SET NEW.tenant_id = (SELECT tenant_id FROM services WHERE id = NEW.featurable_id AND tenant_id <> master_id);
      END IF;
    SQL
  end

  trigger 'features_plans' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM features WHERE id = NEW.feature_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'fields_definitions' do
    <<~SQL
      IF NEW.account_id <> master_id THEN
        SET NEW.tenant_id = NEW.account_id;
      END IF;
    SQL
  end

  trigger 'forums' do
    <<~SQL
      IF NEW.account_id <> master_id THEN
        SET NEW.tenant_id = NEW.account_id;
      END IF;
    SQL
  end

  trigger 'invitations' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM accounts WHERE id = NEW.account_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'invoices' do
    <<~SQL
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
  end

  trigger 'line_items' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM invoices WHERE id = NEW.invoice_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'mail_dispatch_rules' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM accounts WHERE id = NEW.account_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'message_recipients' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM messages WHERE id = NEW.message_id AND tenant_id <> master_id);
    SQL
  end

  # FIXME: this one is actually weird, the relation is polymorphic but the type is *always* Account

  trigger 'messages' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM accounts WHERE id = NEW.sender_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'metrics' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM services WHERE id = NEW.service_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'moderatorships' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM forums WHERE id = NEW.forum_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'payment_transactions' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM invoices WHERE id = NEW.invoice_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'plan_metrics' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM plans WHERE id = NEW.plan_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'plans' do
    <<~SQL
      IF NEW.type = 'AccountPlan' AND NEW.issuer_id <> master_id THEN
        SET NEW.tenant_id = NEW.issuer_id;
      ELSEIF NEW.type = 'ApplicationPlan' OR NEW.type = 'ServicePlan' THEN
        SET NEW.tenant_id = (SELECT tenant_id FROM services WHERE id = NEW.issuer_id AND tenant_id <> master_id);
      END IF;
    SQL
  end

  trigger 'policies' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM accounts WHERE id = NEW.account_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'posts' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM forums WHERE id = NEW.forum_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'pricing_rules' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM plans WHERE id = NEW.plan_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'profiles' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM accounts WHERE id = NEW.account_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'referrer_filters' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM cinstances WHERE id = NEW.application_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'services' do
    <<~SQL
      IF NEW.account_id <> master_id THEN
          SET NEW.tenant_id = NEW.account_id;
      END IF;
    SQL
  end

  trigger 'settings' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM accounts WHERE id = NEW.account_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'authentication_providers' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM accounts WHERE id = NEW.account_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'slugs' do
    <<~SQL
      IF NEW.sluggable_type = 'Profile' THEN
        SET NEW.tenant_id = (SELECT tenant_id FROM profiles WHERE id = NEW.sluggable_id AND tenant_id <> master_id);
      ELSEIF NEW.sluggable_type = 'Service' THEN
        SET NEW.tenant_id = (SELECT tenant_id FROM services WHERE id = NEW.sluggable_id AND tenant_id <> master_id);
      END IF;
    SQL
  end

  trigger 'topic_categories' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM forums WHERE id = NEW.forum_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'topics' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM forums WHERE id = NEW.forum_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'usage_limits' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM metrics WHERE id = NEW.metric_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'user_topics' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM topics WHERE id = NEW.topic_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'users' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM accounts WHERE id = NEW.account_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'web_hooks' do
    <<~SQL
      IF NEW.account_id <> master_id THEN
          SET NEW.tenant_id = NEW.account_id;
      END IF;
    SQL
  end

  trigger 'categories' do
    <<~SQL
      IF NEW.account_id <> master_id THEN
        SET NEW.tenant_id = NEW.account_id;
      END IF;
    SQL
  end

  trigger 'category_types' do
    <<~SQL
      IF NEW.account_id <> master_id THEN
        SET NEW.tenant_id = NEW.account_id;
      END IF;
    SQL
  end

  trigger 'tags' do
    <<~SQL
      IF NEW.account_id <> master_id THEN
        SET NEW.tenant_id = NEW.account_id;
      END IF;
    SQL
  end

  trigger 'taggings' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM tags WHERE id = NEW.tag_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'legal_terms' do
    <<~SQL
      IF NEW.account_id <> master_id THEN
        SET NEW.tenant_id = NEW.account_id;
      END IF;
    SQL
  end

  trigger 'legal_term_versions' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM legal_terms WHERE id = NEW.legal_term_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'legal_term_acceptances' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM legal_terms WHERE id = NEW.legal_term_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'legal_term_bindings' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM legal_terms WHERE id = NEW.legal_term_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'member_permissions' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM users WHERE id = NEW.user_id);
    SQL
  end

  trigger 'cms_sections' do
    <<~SQL
      IF NEW.provider_id <> master_id THEN
        SET NEW.tenant_id = NEW.provider_id;
      END IF;
    SQL
  end

  trigger 'cms_permissions' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM cms_groups WHERE id = NEW.group_id);
    SQL
  end

  trigger 'cms_groups' do
    <<~SQL
      IF NEW.provider_id <> master_id THEN
        SET NEW.tenant_id = NEW.provider_id;
      END IF;
    SQL
  end

  # due to table renaming you might have this older trigger on that table
  trigger 'cms_group_sections' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM cms_groups WHERE id = NEW.group_id);
    SQL
  end

  trigger 'cms_templates' do
    <<~SQL
      IF (master_id IS NULL OR NEW.provider_id <> master_id) THEN
        SET NEW.tenant_id = NEW.provider_id;
      END IF;
    SQL
  end

  trigger 'cms_templates_versions' do
    <<~SQL
      IF NEW.provider_id <> master_id THEN
        SET NEW.tenant_id = NEW.provider_id;
      END IF;
    SQL
  end

  trigger 'cms_files' do
    <<~SQL
      IF NEW.provider_id <> master_id THEN
        SET NEW.tenant_id = NEW.provider_id;
      END IF;
    SQL
  end

  trigger 'log_entries' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM accounts WHERE id = NEW.provider_id AND (NOT master OR master is NULL));
    SQL
  end

  trigger 'cms_redirects' do
    <<~SQL
      IF NEW.provider_id <> master_id THEN
        SET NEW.tenant_id = NEW.provider_id;
      END IF;
    SQL
  end

  trigger 'proxies' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM services WHERE id = NEW.service_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'backend_apis' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM accounts WHERE id = NEW.account_id AND (NOT master OR master is NULL));
    SQL
  end

  trigger 'backend_api_configs' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM backend_apis WHERE id = NEW.backend_api_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'proxy_rules' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM proxies WHERE id = NEW.proxy_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'provider_constraints' do
    <<~SQL
      SET NEW.tenant_id = NEW.provider_id;
    SQL
  end

  trigger 'proxy_configs' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM proxies WHERE id = NEW.proxy_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'access_tokens' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM users WHERE id = NEW.owner_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'event_store_events' do
    <<~SQL
      SET NEW.tenant_id = NEW.provider_id;
    SQL
  end

  trigger 'go_live_states' do
    <<~SQL
      IF NEW.account_id <> master_id THEN
        SET NEW.tenant_id = NEW.account_id;
      END IF;
    SQL
  end

  trigger 'notification_preferences' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM users WHERE id = NEW.user_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'onboardings' do
    <<~SQL
      IF NEW.account_id <> master_id THEN
        SET NEW.tenant_id = NEW.account_id;
      END IF;
    SQL
  end

  trigger 'payment_details' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM accounts WHERE id = NEW.account_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'payment_intents' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM invoices WHERE id = NEW.invoice_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'payment_gateway_settings' do
    <<~SQL
      IF NEW.account_id <> master_id THEN
        SET NEW.tenant_id = NEW.account_id;
      END IF;
    SQL
  end

  trigger 'service_tokens' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM services WHERE id = NEW.service_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'sso_authorizations' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM users WHERE id = NEW.user_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'provided_access_tokens' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM users WHERE id = NEW.user_id AND tenant_id <> master_id);
    SQL
  end

  # FIXME: This will not work when we have more than 1 oidc_configurable_type
  trigger 'oidc_configurations' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM proxies WHERE id = NEW.oidc_configurable_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'gateway_configurations' do
    <<~SQL
      SET NEW.tenant_id = (SELECT tenant_id FROM proxies WHERE id = NEW.proxy_id AND tenant_id <> master_id);
    SQL
  end

  trigger 'email_configurations' do
    <<~SQL
      IF NEW.account_id <> master_id THEN
          SET NEW.tenant_id = NEW.account_id;
      END IF;
    SQL
  end

  trigger 'annotations' do
    definitions = Annotating.models.map do |model|
      [
        "NEW.annotated_type = '#{model}'",
        "SET NEW.tenant_id = (SELECT tenant_id FROM #{model.table_name} WHERE id = NEW.annotated_id AND tenant_id <> master_id);"
      ]
    end

    <<~SQL
      IF #{definitions.map{ _1.join(" THEN\n") }.join("\nELSEIF ")}
      END IF;
    SQL
  end

  procedure 'sp_invoices_friendly_id', invoice_id: 'bigint' do
    <<~SQL
      BEGIN
        DECLARE _provider_account_id bigint(20);
        DECLARE _period date;
        DECLARE _friendly_id varchar(255);

        SELECT provider_account_id, period, friendly_id
        INTO _provider_account_id, _period, _friendly_id
        FROM invoices
        WHERE invoices.id = invoice_id;

        IF _friendly_id IS NULL OR _friendly_id = 'fix' THEN
          SET @numbering_period = (SELECT numbering_period
                                   FROM billing_strategies
                                   WHERE account_id = _provider_account_id
                                   LIMIT 1);

          IF @numbering_period = 'monthly' THEN
            SET @invoice_prefix_format = "%Y-%m";
          ELSE
            SET @invoice_prefix_format = "%Y";
          END IF;

          SET @invoice_prefix = DATE_FORMAT(_period, @invoice_prefix_format);

          UPDATE invoices i INNER JOIN invoice_counters c
          ON i.provider_account_id = c.provider_account_id AND c.invoice_prefix = @invoice_prefix
          SET
            i.friendly_id = CONCAT(@invoice_prefix, '-', LPAD(COALESCE(c.invoice_count, 0) + 1, 8, '0')),
            c.invoice_count = c.invoice_count + 1,
            c.updated_at = CURRENT_TIMESTAMP()
          WHERE i.id = invoice_id;
        END IF;
      END;
    SQL
  end
end
