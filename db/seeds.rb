require 'dotenv/rails-now'

if Rails.env.test? || System::Application.config.three_scale.core.fake_server
  require Rails.root.join('test/test_helpers/backend')
  TestHelpers::Backend::MockCore.mock_core!
end


master_name = ENV.fetch('MASTER_NAME', 'Master Account')
master_service = ENV.fetch('MASTER_SERVICE', 'Master Service')
master_plan = ENV.fetch('MASTER_PLAN', 'Master Plan')
master_domain = ENV.fetch('MASTER_DOMAIN', '').presence
master_access_code = ENV.fetch('MASTER_ACCESS_CODE', '')

master = Account.create!(name: master_name) do |account|
  account.subdomain = master_domain
  account.master = true
  account.provider = true
  account.state = 'approved'
  account.site_access_code = master_access_code
end

master.provider_account = master
master.save!

FieldsDefinition.create_defaults(master)

if Rails.env.development?
  FieldsDefinition.create([
    {
      account: master,
      target: 'Account',
      hidden: false,
      required: false,
      label: 'Are you interested in 3scale on-premises?',
      name: 'API_Onprem_3s__c',
      choices_for_views: "Yes, I'm interested in on-premises \n No, I'm only interested in SaaS"
    },
    {
      account: master,
      target: 'Account',
      hidden: false,
      required: false,
      label: 'At what stage is your API Project?',
      name: 'API_Status_3s__c',
      choices_for_views: 'In design, In development, Live'
    },
    {
      account: master,
      target: 'Account',
      hidden: false,
      required: false,
      label: 'What is the purpose of your API?',
      name: 'API_Purpose_3s__c',
      choices_for_views: 'Integration point for customers, Integration point for partners,' \
        'Content/media distribution, Mobile backend, E-commerce and/or affiliate program,' \
        'API-based business model, Company internal integration'
    }
  ])
end

master_login = ENV.fetch('MASTER_USER', 'master')
master_password = ENV.fetch('MASTER_PASSWORD') { SecureRandom.base64(32) }

master_user = User.create!(username: master_login,
             password: master_password, password_confirmation: master_password) do |user|
  user.signup_type = 'minimal'
  user.account = master
  user.role = :admin
  user.activate!
end

# Creating the master service
master_service = Service.create!(account: master, name: master_service)
master_service.service_plans.default!(ServicePlan.first!)

# Master needs to be contracted with an ApplicationPlan
application_plan = ApplicationPlan.create!(issuer: master_service, name: master_plan)
master_service.update_attribute(:default_application_plan, application_plan)
range = [0] | Alert::ALERT_LEVELS
master_service.notification_settings = { web_buyer: range, email_buyer: range, web_provider: range, email_provider: range}
master_service.save!
application_plan.create_contract_with! master

# Setting the default account plan for master (plan to which provider will subscribe)
account_plan = AccountPlan.create!(issuer: master, name: 'Default account plan')
master.default_account_plan = account_plan
master.save!

# Setting the default application plan for master service (plan to which provider will subscribe)
provider_plan = ENV.fetch('PROVIDER_PLAN', 'enterprise')
plan = ApplicationPlan.create!(issuer: master_service, name: provider_plan)
master_service.application_plans.default!(plan)

# Enable account_plans / service_plans and end_users plans for Master
%i(end_users account_plans service_plans).each do |setting|
  master.settings.send(setting).show!
end
master.settings.allow_branding!

# Adding default metrics for Master API
{billing: 'Billing API', account: 'Account Management API', analytics: 'Analytics API'}.each do |system_name, description|
  master_service.metrics.create!(system_name: system_name, unit: 'hit', friendly_name: description)
end

###
#  Creating Provider Account
###

provider_name = ENV.fetch('PROVIDER_NAME', 'Provider Name')
provider_subdomain = ENV.fetch('TENANT_NAME', 'provider')
sample_data = ENV.fetch('SAMPLE_DATA', '1') != '0'

provider = Account.create!(name: provider_name) do |account|
  account.subdomain = provider_subdomain
  account.provider_account = master
  account.provider = true
  account.sample_data = sample_data
end

# Master no longer has to be a provider
master.update_columns(provider: false)

###
#  Creating Provider User
###

user_login = ENV.fetch('USER_LOGIN', 'admin')
user_email = ENV.fetch('USER_EMAIL', "#{user_login}@#{provider.domain}")
user_password = ENV.fetch('USER_PASSWORD') { SecureRandom.base64(32) }

user = User.create!(username: user_login, password: user_password, password_confirmation: user_password) do |user|
  user.signup_type = :minimal
  user.account = provider
  user.role = :admin
  user.email = user_email
  user.activate!
  user.account.create_onboarding
end

###
#  Setting up APIcast authentication
###

apicast_access_token = master_user.access_tokens.create!(name: 'APIcast', scopes: %w(account_management), permission: 'ro') do |token|
  if (value = ENV['APICAST_ACCESS_TOKEN'].presence)
    token.value = value
  end
end.value


master_access_token = master_user.access_tokens.create!(name: 'Master Token', scopes: %w(account_management), permission: 'rw') do |token|
  if (value = ENV['MASTER_ACCESS_TOKEN'])
    token.value = value
  end
end.value

if (admin_access_token = ENV['ADMIN_ACCESS_TOKEN'])
  access_token = user.access_tokens.build(name: 'Administration', permission: 'rw')
  access_token.scopes = access_token.class.scopes.values
  access_token.value = admin_access_token
  access_token.save!
end


###
#  Creating impersonation admin user for provider
###

impersonation_admin = provider.users.build_with_fields
impersonation_admin.account = provider
impersonation_admin.role = :admin
impersonation_admin.signup_type = :minimal

impersonation_admin_config = ThreeScale.config.impersonation_admin
impersonation_admin_username = impersonation_admin_config['username']
impersonation_admin.attributes = {
  username: impersonation_admin_username,
  email: "#{impersonation_admin_username}+#{provider.self_domain}@#{impersonation_admin_config['domain']}",
  first_name: '3scale',
  last_name: 'Admin'
}

impersonation_admin.save!
impersonation_admin.activate!

###
#  Creating Sample Data
###

SignupWorker.enqueue(provider)

###
#  Enabling Provider Switches
###

provider.force_upgrade_to_provider_plan!(plan)

###
# Basic enabled/disabled switches
###

Settings.basic_enabled_switches.each do |name|
  provider.settings.public_send("show_#{name}")
end

Settings.basic_disabled_switches.each do |name|
  provider.settings.public_send("hide_#{name}")
end

# Import sample data in dev mode
if sample_data and Rails.env.development?
  provider.create_sample_data!
  provider.update_columns(sample_data: false)
end

# Import CMS templates
SimpleLayout.new(provider).import! if ENV.fetch('CMS_TEMPLATES', Rails.env.development?).presence

puts '='*80
puts
puts 'Setup Completed'
puts
puts "Root Domain: #{ThreeScale.config.superdomain}"

if master_login && master_password
  puts
  puts "Master Domain: #{master.admin_domain}"
  puts "Master User Login: #{master_login}"
  puts "Master User Password: #{master_password}"
  puts "Master RW access token: #{master_access_token}"
  if master_access_code.present?
    puts "Master Access Code: #{master_access_code}"
  end
  puts
end

puts "Provider Admin Domain: #{provider.admin_domain}"
puts "Provider Portal Domain: #{provider.domain}"
puts "Provider User Login: #{user_login}"
puts "Provider User Password: #{user_password}"
puts "APIcast Access Token: #{apicast_access_token}"
if admin_access_token
  puts "Admin Access Token: #{admin_access_token}"
end
puts
puts '='*80
