# frozen_string_literal: true

require 'system/database'

namespace :multitenant do

  task :test => :environment do
    # ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])
    ActiveRecord::Base.establish_connection(:test)
  end

  desc "Loads triggers to test database"
  task 'test:triggers' => ['multitenant:test', 'multitenant:triggers']

  namespace :triggers do
    task create: :environment do
      System::Database.triggers.each do |t|
        ActiveRecord::Base.connection.execute(t.create)
      end
    end

    task drop: :environment do
      System::Database.triggers.each do |t|
        ActiveRecord::Base.connection.execute(t.drop)
      end
    end
  end

  desc 'Recreates the DB triggers (delete+create)'
  task triggers: :environment do
    puts "Recreating trigger, see log/#{Rails.env}.log"
    triggers = System::Database.triggers
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
    ProvidedAccessToken.update_all "tenant_id = account_id WHERE account_id <> #{MASTER_ID}"
    # FIXME: This will not work when we have more than 1 oidc_configurable_type
    OIDConfiguration.update_all "tenant_id = (SELECT tenant_id FROM proxies WHERE id = oidc_configurable_id AND tenant_id <> #{MASTER_ID})"
  end
end

task 'db:triggers' => 'multitenant:triggers' # Alias for 'multitenant:triggers'. TODO: Move the task to the 'db' namespace and refactor so a trigger can be defined not only for setting the tenant_id
Rake::Task['db:seed'].enhance(['multitenant:triggers'])
