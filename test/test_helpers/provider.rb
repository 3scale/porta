# frozen_string_literal: true

module TestHelpers
  module Provider
    include ActiveJob::TestHelper

    def create_a_complete_provider
      ::Sidekiq::Testing.inline! do
        perform_enqueued_jobs do
          provider = FactoryBot.create(:provider_account, :with_a_buyer)
          provider.create_onboarding!
          SimpleLayout.new(provider).import!
          buyer = provider.buyers.take
          service = FactoryBot.create(:service, account: provider)
          FactoryBot.create(:account_contract, plan: FactoryBot.create(:account_plan, issuer: provider))
          FactoryBot.create(:application_contract, user_account: provider, service: provider.default_service)
          FactoryBot.create(:service_contract, plan: service.service_plans.take, user_account: buyer)
          FactoryBot.create(:api_docs_service, account: provider)
          ProviderConstraints.null(provider).save!
          FactoryBot.create(:access_token, owner: provider.admin_user, scopes: 'account_management', permission: 'rw')

          FactoryBot.create(:annotation, annotated: provider.default_service)
          FactoryBot.create(:limit_alert, account: provider, cinstance: provider.application_contracts.take)
          app_plan = FactoryBot.create(:application_plan, issuer: service)
          metric = service.metrics.take
          FactoryBot.create(:usage_limit, plan: app_plan, metric:)
          FactoryBot.create(:plan_metric, plan: app_plan, metric:, visible: false, limits_only_text: false)
          FactoryBot.create(:pricing_rule, plan: app_plan, metric:)
          FactoryBot.create(:user_session, user: provider.admin_user)
          account_feature = FactoryBot.create(:feature, featurable: provider)
          provider.account_plans.take.features_plans.create!(feature: account_feature)
          feature = FactoryBot.create(:feature, featurable: service)
          app_plan.features_plans.create!(feature: feature)
          provider.admin_user.provided_access_tokens.create!(value: Random.alphanumeric)
          FactoryBot.create(:profile, account: provider)
          service = provider.default_service
          FactoryBot.create(:service_token, service:)
          FactoryBot.create(:proxy_config, proxy: service.proxy)
          invoice = FactoryBot.create(:invoice, provider_account: provider, buyer_account: buyer)
          FactoryBot.create(:line_item_plan_cost, invoice:, contract: provider.bought_cinstance, cinstance_id: provider.bought_cinstance.id)
          FactoryBot.create(:line_item, invoice:)
          FactoryBot.create(:line_item_variable_cost, metric: service.metrics.take, invoice:)
          FactoryBot.create(:payment_intent, invoice:)
          FactoryBot.create(:payment_transaction, success: true, invoice:)
          FactoryBot.create(:payment_detail, account: provider)
          FactoryBot.create(:invoice_counter, provider_account: provider, invoice_prefix: ::Time.now.year.to_s)
          FactoryBot.create(:webhook, account: provider, account_created_on: true, active: true)
          FactoryBot.create(:policy, account: provider, name: 'my-policy', version: '1.0')
          FactoryBot.create(:invitation, account: buyer) # invitation without an associated user
          FactoryBot.create(:invitation, account: buyer, user: buyer.users.take)
          FactoryBot.create(:member, account: provider, member_permission_ids: ['plans'])
          FactoryBot.create(:email_configuration, account: provider)
          FactoryBot.create(:application_key, application: service.cinstances.take)
          DeletedObject.create(object: provider.admin_user, owner: provider)
          FactoryBot.create(:cms_email_template, provider:)
          FactoryBot.create(:cms_builtin_legal_term, provider:)
          CMS::LegalTerm.create(account_id: provider.id, name: "test", body: "another test")
          MailDispatchRule.create(account_id: provider.id, system_operation_id: 1, emails: provider.first_admin.email)
          MailDispatchRule.create(account_id: buyer.id, system_operation_id: 1, emails: buyer.first_admin.email)
          FactoryBot.create(:cms_builtin_static_page, provider:)
          cms_croup = FactoryBot.create(:cms_group, provider:)
          cms_croup.group_sections.create(:section => provider.provided_sections.first)
          buyer.permissions.create(:group => cms_croup)
          buyer.save!
          FactoryBot.create(:referrer_filter, application: provider.application_contracts.take)
          FactoryBot.create(:partner, providers: [provider], )
          NotificationPreferences.create(user: provider.admin_user)
          FactoryBot.create(:prepaid_billing, account: provider)
          service.proxy.gateway_configuration.save!

          FactoryBot.create(:oidc_configuration, oidc_configurable: service.proxy)
          authentication_provider = FactoryBot.create(:auth0_authentication_provider, account: provider)
          FactoryBot.create(:sso_authorization, user: provider.admin_user, authentication_provider:)
          FactoryBot.create(:keycloak_self_authentication_provider, account: provider)
          FactoryBot.create(:github_authentication_provider, account: provider)
          FactoryBot.create(:redhat_customer_portal_authentication_provider, account: provider)
          provider.authentication_providers.create!({ type: "AuthenticationProvider::Custom", client_id: 'id', client_secret: 'secret', site: 'http://example.com', account: provider }, { without_protection: true })
          provider.authentication_providers.create!({ type: "AuthenticationProvider::ServiceDiscoveryProvider", client_id: 'id', client_secret: 'secret', site: 'http://example.com', account: provider }, {without_protection: true })

          forum = FactoryBot.create(:forum, account: provider)
          topic = FactoryBot.create(:topic, user: provider.admin_user, forum:)
          FactoryBot.create(:topic_category, forum:)
          FactoryBot.create(:post, user: provider.admin_user, forum:, topic:)
          UserTopic.create({user: provider.admin_user, topic:}, {without_protection: true})
          Moderatorship.create({user: provider.admin_user, forum:}, {without_protection: true})

          Configuration::Value.create(configurable: provider, name: "foo", value: "bar")

          FactoryBot.create(:cms_portlet, provider:)
          LatestForumPostsPortlet.create!(provider:, portlet_type: 'LatestForumPostsPortlet', system_name: 'name', posts: forum.posts.count)
          TableOfContentsPortlet.create!(provider:, portlet_type: 'TableOfContentsPortlet', system_name: 'name', section_id: provider.provided_sections.first.id)
          CMS::Redirect.new.tap do |redirect|
            redirect.assign_attributes({source: "a", target: "b", provider:}, {without_protection: true})
          end.save!

          provider
        end
      end
    end
  end
end
