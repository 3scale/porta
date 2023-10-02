# frozen_string_literal: true

require 'system/database/oracle'

System::Database::Oracle.define do
  trigger 'accounts' do
    <<~SQL
      IF :new.buyer = 1 THEN
        :new.tenant_id := :new.provider_account_id;
      END IF;
    SQL
  end

  trigger 'audits' do
    <<~SQL
      IF :new.provider_id <> master_id THEN
        :new.tenant_id := :new.provider_id;
      END IF;
    SQL
  end

  trigger 'alerts' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM accounts WHERE id = :new.account_id AND (master <> 1 OR master is NULL);
    SQL
  end

  trigger 'api_docs_services' do
    <<~SQL
      IF :new.account_id <> master_id THEN
        :new.tenant_id := :new.account_id;
      END IF;
    SQL
  end

  trigger 'application_keys' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM cinstances WHERE id = :new.application_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'billing_strategies' do
    <<~SQL
      IF :new.account_id <> master_id THEN
        :new.tenant_id := :new.account_id;
      END IF;
    SQL
  end

  trigger 'cinstances' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM plans WHERE id = :new.plan_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'configuration_values' do
    <<~SQL
      IF :new.configurable_type = 'Account' AND :new.configurable_id <> master_id THEN
        :new.tenant_id := :new.configurable_id;
      ELSIF :new.configurable_type = 'Service' THEN
         SELECT tenant_id INTO :new.tenant_id FROM services WHERE id = :new.configurable_id AND tenant_id <> master_id;
      END IF;
    SQL
  end

  trigger 'features' do
    <<~SQL
      IF :new.featurable_type = 'Account' AND :new.featurable_id <> master_id THEN
        :new.tenant_id := :new.featurable_id;
      ELSIF :new.featurable_type = 'Service' THEN
        SELECT tenant_id INTO :new.tenant_id FROM services WHERE id = :new.featurable_id AND tenant_id <> master_id;
      END IF;
    SQL
  end

  trigger 'features_plans' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM features WHERE id = :new.feature_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'fields_definitions' do
    <<~SQL
      IF :new.account_id <> master_id THEN
        :new.tenant_id := :new.account_id;
      END IF;
    SQL
  end

  trigger 'forums' do
    <<~SQL
      IF :new.account_id <> master_id THEN
        :new.tenant_id := :new.account_id;
      END IF;
    SQL
  end

  trigger 'invitations' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM accounts WHERE id = :new.account_id AND tenant_id <> master_id;
    SQL
  end

  invoice_variables = <<~SQL
    v_numbering_period varchar(255);
    v_invoice_prefix_format varchar(255);
    v_invoice_prefix varchar(255);
    v_invoice_count NUMBER;
    v_chosen_sufix NUMBER;
    v_invoice_counter_id NUMBER;
  SQL

  trigger 'invoices', with_variables: invoice_variables do
    <<~SQL
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
  end

  trigger 'line_items' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM invoices WHERE id = :new.invoice_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'mail_dispatch_rules' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM accounts WHERE id = :new.account_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'message_recipients' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM messages WHERE id = :new.message_id AND tenant_id <> master_id;
    SQL
  end

  # FIXME: this one is actually weird, the relation is polymorphic but the type is *always* Account

  trigger 'messages' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM accounts WHERE id = :new.sender_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'metrics' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM services WHERE id = :new.service_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'moderatorships' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM forums WHERE id = :new.forum_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'payment_transactions' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM invoices WHERE id = :new.invoice_id AND tenant_id <> master_id;
    SQL
  end


  trigger 'plan_metrics' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM plans WHERE id = :new.plan_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'plans' do
    <<~SQL
      IF :new.type = 'AccountPlan' AND :new.issuer_id <> master_id THEN
        :new.tenant_id := :new.issuer_id;
      ELSIF :new.type = 'ApplicationPlan' OR :new.type = 'ServicePlan' THEN
        SELECT tenant_id INTO :new.tenant_id FROM services WHERE id = :new.issuer_id AND tenant_id <> master_id;
      END IF;
    SQL
  end

  trigger 'policies' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM accounts WHERE id = :new.account_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'posts' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM forums WHERE id = :new.forum_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'pricing_rules' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM plans WHERE id = :new.plan_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'profiles' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM accounts WHERE id = :new.account_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'referrer_filters' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM cinstances WHERE id = :new.application_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'services' do
    <<~SQL
      IF :new.account_id <> master_id THEN
          :new.tenant_id := :new.account_id;
      END IF;
    SQL
  end

  trigger 'settings' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM accounts WHERE id = :new.account_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'authentication_providers' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM accounts WHERE id = :new.account_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'slugs' do
    <<~SQL
      IF :new.sluggable_type = 'Profile' THEN
        SELECT tenant_id INTO :new.tenant_id FROM profiles WHERE id = :new.sluggable_id AND tenant_id <> master_id;
      ELSIF :new.sluggable_type = 'Service' THEN
        SELECT tenant_id INTO :new.tenant_id FROM services WHERE id = :new.sluggable_id AND tenant_id <> master_id;
      END IF;
    SQL
  end

  trigger 'topic_categories' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM forums WHERE id = :new.forum_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'topics' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM forums WHERE id = :new.forum_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'usage_limits' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM metrics WHERE id = :new.metric_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'user_topics' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM topics WHERE id = :new.topic_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'users' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM accounts WHERE id = :new.account_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'web_hooks' do
    <<~SQL
      IF :new.account_id <> master_id THEN
          :new.tenant_id := :new.account_id;
      END IF;
    SQL
  end

  trigger 'categories' do
    <<~SQL
      IF :new.account_id <> master_id THEN
        :new.tenant_id := :new.account_id;
      END IF;
    SQL
  end

  trigger 'category_types' do
    <<~SQL
      IF :new.account_id <> master_id THEN
        :new.tenant_id := :new.account_id;
      END IF;
    SQL
  end

  trigger 'tags' do
    <<~SQL
      IF :new.account_id <> master_id THEN
        :new.tenant_id := :new.account_id;
      END IF;
    SQL
  end

  trigger 'taggings' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM tags WHERE id = :new.tag_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'legal_terms' do
    <<~SQL
      IF :new.account_id <> master_id THEN
        :new.tenant_id := :new.account_id;
      END IF;
    SQL
  end

  trigger 'legal_term_versions' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM legal_terms WHERE id = :new.legal_term_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'legal_term_acceptances' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM legal_terms WHERE id = :new.legal_term_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'legal_term_bindings' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM legal_terms WHERE id = :new.legal_term_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'member_permissions' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM users WHERE id = :new.user_id;
    SQL
  end

  trigger 'cms_sections' do
    <<~SQL
      IF :new.provider_id <> master_id THEN
        :new.tenant_id := :new.provider_id;
      END IF;
    SQL
  end

  trigger 'cms_permissions' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM cms_groups WHERE id = :new.group_id;
    SQL
  end

  trigger 'cms_groups' do
    <<~SQL
      IF :new.provider_id <> master_id THEN
        :new.tenant_id := :new.provider_id;
      END IF;
    SQL
  end

  # due to table renaming you might have this older trigger on that table
  trigger 'cms_group_sections' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM cms_groups WHERE id = :new.group_id;
    SQL
  end

  trigger 'cms_templates' do
    <<~SQL
      IF (master_id IS NULL OR :new.provider_id <> master_id) THEN
        :new.tenant_id := :new.provider_id;
      END IF;
    SQL
  end

  trigger 'cms_templates_versions' do
    <<~SQL
      IF :new.provider_id <> master_id THEN
        :new.tenant_id := :new.provider_id;
      END IF;
    SQL
  end

  trigger 'cms_files' do
    <<~SQL
      IF :new.provider_id <> master_id THEN
        :new.tenant_id := :new.provider_id;
      END IF;
    SQL
  end

  trigger 'log_entries' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM accounts WHERE id = :new.provider_id AND (master <> 1 OR master is NULL);
    SQL
  end

  trigger 'cms_redirects' do
    <<~SQL
      IF :new.provider_id <> master_id THEN
        :new.tenant_id := :new.provider_id;
      END IF;
    SQL
  end

  trigger 'proxies' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM services WHERE id = :new.service_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'backend_apis' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM accounts WHERE id = :new.account_id AND (master <> 1 OR master is NULL);
    SQL
  end

  trigger 'backend_api_configs' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM backend_apis WHERE id = :new.backend_api_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'proxy_rules' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM proxies WHERE id = :new.proxy_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'provider_constraints' do
    <<~SQL
      :new.tenant_id := :new.provider_id;
    SQL
  end

  trigger 'proxy_configs' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM proxies WHERE id = :new.proxy_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'access_tokens' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM users WHERE id = :new.owner_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'event_store_events' do
    <<~SQL
      :new.tenant_id := :new.provider_id;
    SQL
  end

  trigger 'notification_preferences' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM users WHERE id = :new.user_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'go_live_states' do
    <<~SQL
      IF :new.account_id <> master_id THEN
        :new.tenant_id := :new.account_id;
      END IF;
    SQL
  end

  trigger 'notification_preferences' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM users WHERE id = :new.user_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'onboardings' do
    <<~SQL
      IF :new.account_id <> master_id THEN
        :new.tenant_id := :new.account_id;
      END IF;
    SQL
  end

  trigger 'payment_details' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM accounts WHERE id = :new.account_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'payment_intents' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM invoices WHERE id = :new.invoice_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'payment_gateway_settings' do
    <<~SQL
      IF :new.account_id <> master_id THEN
        :new.tenant_id := :new.account_id;
      END IF;
    SQL
  end

  trigger 'service_tokens' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM services WHERE id = :new.service_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'sso_authorizations' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM users WHERE id = :new.user_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'provided_access_tokens' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM users WHERE id = :new.user_id AND tenant_id <> master_id;
    SQL
  end

  # FIXME: This will not work when we have more than 1 oidc_configurable_type
  trigger 'oidc_configurations' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM proxies WHERE id = :new.oidc_configurable_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'gateway_configurations' do
    <<~SQL
      SELECT tenant_id INTO :new.tenant_id FROM proxies WHERE id = :new.proxy_id AND tenant_id <> master_id;
    SQL
  end

  trigger 'email_configurations' do
    <<~SQL
      IF :new.account_id <> master_id THEN
          :new.tenant_id := :new.account_id;
      END IF;
    SQL
  end

  trigger 'annotations' do
    definitions = Annotating.models.map do |model|
      [
        ":new.annotated_type = '#{model}'",
        "SELECT tenant_id INTO :new.tenant_id FROM #{model.table_name} WHERE id = :new.annotated_id AND tenant_id <> master_id;"
      ]
    end

    <<~SQL
      IF #{definitions.map{ _1.join(" THEN\n") }.join("\nELSEIF ")}
      END IF;
    SQL
  end

  procedure 'sp_invoices_friendly_id', invoice_id: 'NUMBER' do
    <<~SQL
        v_provider_account_id NUMBER;
        v_period date;
        v_friendly_id varchar(255);
        v_numbering_period varchar(255);
        v_invoice_prefix_format varchar(255);
        v_invoice_prefix varchar(255);
        v_invoice_counter_id NUMBER;
        v_invoice_count NUMBER;
      BEGIN
        SELECT provider_account_id, period, friendly_id
        INTO v_provider_account_id, v_period, v_friendly_id
        FROM invoices
        WHERE invoices.id = invoice_id
        AND ROWNUM = 1;

        IF v_friendly_id IS NULL OR v_friendly_id = 'fix' THEN
          SELECT numbering_period
          INTO v_numbering_period
          FROM billing_strategies
          WHERE account_id = v_provider_account_id
          AND ROWNUM = 1;

          IF v_numbering_period = 'monthly' THEN
            v_invoice_prefix_format := 'YYYY-MM';
          ELSE
            v_invoice_prefix_format := 'YYYY';
          END IF;

          v_invoice_prefix := TO_CHAR(v_period, v_invoice_prefix_format);

          SELECT id, invoice_count
          INTO v_invoice_counter_id, v_invoice_count
          FROM invoice_counters
          WHERE provider_account_id = v_provider_account_id AND invoice_prefix = v_invoice_prefix
          AND ROWNUM = 1
          FOR UPDATE;

          UPDATE invoices
          SET friendly_id = v_invoice_prefix || '-' || LPAD(COALESCE(v_invoice_count, 0) + 1, 8, '0')
          WHERE id = invoice_id;

          UPDATE invoice_counters
          SET invoice_count = invoice_count + 1, updated_at = CURRENT_TIMESTAMP
          WHERE id = v_invoice_counter_id;
        END IF;
      END;
    SQL
  end
end
