# frozen_string_literal: true

# See this for more info: https://github.com/aslakhellesoy/cucumber/wiki/Step-Argument-Transforms

# List of quotes strings:
#
#   "foo"
#   "foo" and "bar"
#   "foo", "bar" and "baz"
#   ...
#
# Transforms them into array of unquoted strings
quoted_list_subpattern = '"[^"]*"(?:(?:,| and) "[^"]*")'

QUOTED_ONE_OR_MORE_PATTERN = "(#{quoted_list_subpattern}*)"
QUOTED_TWO_OR_MORE_PATTERN = "(#{quoted_list_subpattern}+)"
QUOTED_LIST_PATTERN        = QUOTED_ONE_OR_MORE_PATTERN # 1 or more is the default
#UNQUOTED_LIST_PATTERN      =  /((?:\w+(?:,| and| ) +)+(?:\w+))/

Transform /^#{QUOTED_LIST_PATTERN}$/ do |list|
  list.from_sentence.map { |item| item.delete('"') }
end

# unfortunately this transforms almost every string to array
#Transform /^#{UNQUOTED_LIST_PATTERN}$/ do |list|
#  list.from_sentence
#end

# Accounts

PROVIDER = /(provider ".+?"|master provider)/

Transform /^account "(.+?)"$/ do |org_name|
  Account.find_by_org_name!(org_name)
end

Transform /^the provider$/ do  |_|
  @provider or raise ActiveRecord::RecordNotFound, "@provider does not exist"
end

Transform /^provider "(.+?)"$/ do |name|
  # TODO: fix this hacky way of getting master
  if name == 'master'
    Account.master rescue FactoryBot.create(:master_account)
  else
    Account.providers.readonly(false).find_by_org_name!(name)
  end
end

Transform /^(master provider)$/ do |_|
  Account.master
end

Transform /^buyer "([^\"]*)"$/ do |org_name|
  Account.buyers.find_by_org_name!(org_name)
end

# Cinstance / Application
Transform /^the user key of buyer "([^"]*)"$/ do |name|
  Account.buyers.find_by_org_name!(name).bought_cinstance.user_key
end
Transform /^the application id of buyer "([^"]*)"$/ do |name|
  Account.buyers.find_by_org_name!(name).bought_cinstance.application_id
end

Transform /^application "([^"]*)"$/ do |name|
  Cinstance.find_by_name!(name)
end

# Potato CMS

Transform /^CMS Page "(.+?)"$/i do |path|
  CMS::Page.find_by_path!(path)
end

Transform /^CMS Partial "(.+?)"$/i do |path|
  CMS::Partial.find_by_system_name!(path)
end

# CMS
Transform /^page "([^\"]*)"$/ do |title|
  Page.find_by_title!(title)
end

Transform /^page "([^\"]*)" of provider "([^\"]*)"$/ do |title, provider_name|
  provider = Account.providers.find_by_org_name!(provider_name)
  Page.find_by_title_and_account_id!(title, provider.id)
end

Transform /^page at (.*) of provider "([^\"]*)"$/ do |path, provider_name|
  provider = Account.providers.find_by_org_name!(provider_name)
  Page.find_by_path_and_account_id!(path, provider_id)
end

Transform /^section "([^\"]*)" of provider "([^\"]*)"$/ do |name, provider_name|
  provider = Account.providers.readonly(false).find_by_org_name(provider_name)
  provider.provided_sections.find_by_title!(name)
end

Transform /^html block "([^\"]*)"$/ do |name|
  HtmlBlock.find_by_name!(name)
end

Transform /^country "([^"]*)"$/ do |name|
  Country.find_by_name!(name)
end

Transform /^feature "([^"]*)"$/ do |name|
  Feature.find_by_name!(name)
end

# Forum
Transform /^the forum of "([^"]*)"$/ do |name|
  Account.providers.find_by_org_name!(name).forum
end

Transform /^topic "([^\"]+)"$/ do |title|
  Topic.find_by_title!(title)
end

Transform /^post "([^"]*)"$/ do |body|
  post = Post.all.to_a.find { |p| p.body == body }
  assert post
  post
end

Transform /^the last post under topic "([^"]*)"$/ do |topic_title|
  Topic.find_by_title!(topic_title).posts.last
end

Transform /^category "([^"]*)"$/ do |name|
  TopicCategory.find_by_name!(name)
end

# Metric
Transform /^metric "([^"]*)" on application plan "([^"]*)"$/ do |name, plan_name|
  ApplicationPlan.find_by_name!(plan_name).metrics.find_by!(system_name: name)
end

Transform /^metric "([^"]*)"$/ do |name|
  Metric.find_by!(system_name: name)
end

Transform /^method "([^"]*)"$/ do |name|
  current_account.first_service!.metrics.hits.children.find_by!(system_name: name)
end

Transform /^metric "([^"]*)" of provider "([^"]*)$/ do |metric_name, provider_name|
  provider = Account.find_by_org_name!(provider_name)
  provider.first_service!.metrics.find_by!(system_name: name)
end

Transform /^plan "(.+?)"$/ do |name|
  Plan.find_by_name!(name)
end

Transform /^service "(.+?)"$/ do |name|
  Service.find_by_name!(name)
end

Transform /^service plan "(.+?)"$/ do |name|
  ServicePlan.find_by_name!(name)
end

Transform /^account plan "(.+?)"$/ do |name|
  AccountPlan.find_by_name!(name)
end

Transform /^application plan "(.+?)"$/ do |name|
  ApplicationPlan.find_by_name!(name)
end

Transform /^end user plan "(.+?)"$/ do |name|
  EndUserPlan.find_by_name!(name)
end

Transform /^user "([^\"]*)"$/ do |name|
  User.find_by_username!(name)
end

Transform /^legal terms "([^\"]*)"$/ do |name|
  CMS::LegalTerm.find_by_title!(name)
end

Transform /^buyer group "([^\"]*)" of provider "([^\"]*)"$/ do |name, provider_name|
  name
end

Transform /^table:buyer,name,plan$/i do |table|
  table.map_headers! {|header| header.parameterize.underscore.downcase.to_s }
  table.map_column!(:buyer) {|buyer| Account.buyers.find_by_org_name!(buyer) }
  table.map_column!(:plan) {|plan| ApplicationPlan.find_by_name!(plan) }
  table
end

Transform /^table:name,cost per month,setup fee$/i do |table|
  table.map_headers! {|header| header.parameterize.underscore.downcase.to_s }
  table.map_column!(:cost_per_month) {|cost| cost.to_f }
  table.map_column!(:setup_fee) {|setup| setup.to_f }
  table
end

Transform /^table:code,name$/i do |table|
  table.map_headers! {|header| header.parameterize.underscore.downcase.to_s }
  table
end

Transform /^email template "(.+?)"$/ do |name|
  CMS::EmailTemplate.find_by!(system_name: name)
end

Transform /^service "([^\"]*)" of provider "([^\"]*)"$/ do |service_name, provider_name|
  Account.providers.find_by_org_name!(provider_name)
    .services.find_by_name!(service_name)
end

# Finance
Transform /^invoice "(.+?)"$/ do |id|
  Invoice.find_by_id(id) or Invoice.find_by_friendly_id(id) or raise "Couldn't find Invoice with id #{id}"
end

Transform /^(on|off)$/ do |state|
  state == 'on'
end


# Authentication Providers
OAUTH_PROVIDER_OPTIONS = {
  auth0: {
    site: "https://client.auth0.com"
  },
  keycloak: {
    site: "http://localhost:8080/auth/realms/3scale"
  }
}.freeze

Transform /^authentication provider "([^\"]+)"$/ do |authentication_provider_name|
  authentication_provider = @provider.authentication_providers.find_by(name: authentication_provider_name)
  return authentication_provider if authentication_provider

  ap_underscored_name = authentication_provider_name.underscore
  options = OAUTH_PROVIDER_OPTIONS[ap_underscored_name.to_sym]
            .merge(
              {
                system_name: "#{ap_underscored_name}_hex",
                client_id: 'CLIENT_ID',
                client_secret: 'CLIENT_SECRET',
                kind: ap_underscored_name,
                name: authentication_provider_name,
                account_id: @provider.id,
                identifier_key: 'id',
                username_key: 'login',
                trust_email: false
              }
            )

  authentication_provider_class = "AuthenticationProvider::#{authentication_provider_name}".constantize
  authentication_provider_class.create(options)
end
