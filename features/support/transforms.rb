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

ParameterType(
  name: 'list',
  regexp: /#{QUOTED_LIST_PATTERN}/,
  transformer: -> (list) { list.from_sentence.map { |item| item.delete('"') } }
)

# Accounts

PROVIDER = /(provider ".+?"|master provider)/

ParameterType(
  name: 'org_name',
  regexp: /account "(.+?)"/,
  transformer: -> (org_name) {  Account.find_by_org_name!(org_name) }

)

ParameterType(
  name: 'the_provider',
  regexp: /the provider/,
  transformer: -> { @provider or raise ActiveRecord::RecordNotFound, "@provider does not exist" }
)

ParameterType(
  name: 'provider',
  regexp: /provider "(.+?)"/,
  transformer: -> (name) {
    # TODO: fix this hacky way of getting master
    if name == 'master'
      Account.master rescue FactoryBot.create(:master_account)
    else
      Account.providers.readonly(false).find_by_org_name!(name)
    end
  }
)

ParameterType(
  name: 'master_account',
  regexp: /master provider/,
  transformer: -> { Account.master }
)

ParameterType(
  name: 'buyer',
  regexp: /buyer "([^\"]*)"/,
  transformer: -> (name) { Account.buyers.find_by!(org_name: name) }
)

ParameterType(
  name: 'user_key_of_buyer',
  regexp: /the user key of buyer "([^"]*)"/,
  transformer: -> (name) { Account.buyers.find_by_org_name!(name).bought_cinstance.user_key }
)

# Cinstance / Application

ParameterType(
  name: 'application_id_of_buyer',
  regexp: /the application id of buyer "([^"]*)"/,
  transformer: -> (name) { Account.buyers.find_by_org_name!(name).bought_cinstance.application_id }
)

ParameterType(
  name: 'application',
  regexp: /application "([^"]*)"/,
  transformer: -> (name) { Cinstance.find_by_name!(name) }
)

# Potato CMS

ParameterType(
  name: 'cms_page',
  regexp: /CMS Page "(.+?)"/,
  transformer: -> (name) { CMS::Page.find_by_path!(path) }
)

ParameterType(
  name: 'cms_partial',
  regexp: /CMS Partial "(.+?)"/,
  transformer: -> (path) { CMS::Partial.find_by_system_name!(path) }
)

# CMS
ParameterType(
  name: 'page',
  regexp: /page "([^\"]*)"/,
  transformer: -> (title) { Page.find_by_title!(title) }
)

ParameterType(
  name: 'page_of_provider',
  regexp: /page "([^\"]*)" of provider "([^\"]*)"/,
  transformer: -> (title, provider_name) {
    provider = Account.providers.find_by_org_name!(provider_name)
    Page.find_by_title_and_account_id!(title, provider.id)
  }
)

ParameterType(
  name: 'page_at_of_provider',
  regexp: /page at (.*) of provider "([^\"]*)"/,
  transformer: -> (path, provider_name){
    provider = Account.providers.find_by_org_name!(provider_name)
    Page.find_by_path_and_account_id!(path, provider_id)
  }
)

ParameterType(
  name: 'section_of_provider',
  regexp: /section "([^\"]*)" of provider "([^\"]*)"/,
  transformer: -> (name, provider_name) {
    provider = Account.providers.readonly(false).find_by_org_name(provider_name)
    provider.provided_sections.find_by_title!(name)
  }
)

ParameterType(
  name: 'country',
  regexp: /country "([^"]*)"/,
  transformer: -> (name) { Country.find_by_name!(name) }
)

ParameterType(
  name: 'feature',
  regexp: /feature "([^"]*)"/,
  transformer: -> (name) { Feature.find_by_name!(name) }
)

# Forum

ParameterType(
  name: 'forum',
  regexp: /the forum of "([^"]*)"/,
  transformer: -> (name) { Account.providers.find_by_org_name!(name).forum }
)

ParameterType(
  name: 'topic',
  regexp: /the topic "([^"]*)"/,
  transformer: -> (title) { Topic.find_by_title!(title) }
)

ParameterType(
  name: 'post',
  regexp: /post "([^"]*)"/,
  transformer: -> (body) {
    post = Post.all.to_a.find { |p| p.body == body }
    assert post
    post
  }
)

ParameterType(
  name: 'last_post_under_topic',
  regexp: /the last post under topic "([^"]*)"/,
  transformer: -> (topic_title){
    Topic.find_by_title!(topic_title).posts.last
  }
)

ParameterType(
  name: 'category',
  regexp: /category "([^"]*)"/,
  transformer: -> (mame) { TopicCategory.find_by_name!(name) }
)

# Metric
ParameterType(
  name: 'metric_on_application_plan',
  regexp: /metric "([^"]*)" on application plan "([^"]*)"/,
  transformer: -> (name, plan_name) { ApplicationPlan.find_by_name!(plan_name).metrics.find_by!(system_name: name) }
)

ParameterType(
  name: 'metric',
  regexp: /metric "([^"]*)"/,
  transformer: -> (name) { Metric.find_by!(system_name: name) }
)

ParameterType(
  name: 'method',
  regexp: /method "([^"]*)"/,
  transformer: -> (name) { current_account.first_service!.metrics.hits.children.find_by!(system_name: name) }
)

ParameterType(
  name: 'metric_of_provider',
  regexp: /metric "([^"]*)" of provider "([^"]*)/,
  transformer: -> (metric_name, provider_name) {
    provider = Account.find_by_org_name!(provider_name)
    provider.first_service!.metrics.find_by!(system_name: name)
  }
)

ParameterType(
  name: 'plan',
  regexp: /plan "(.+?)"/,
  transformer: -> (name) { Plan.find_by_name!(name) }
)

ParameterType(
  name: 'service',
  regexp: /service "(.+?)"/,
  transformer: -> (name) { Service.find_by_name!(name) }
)


ParameterType(
  name: 'service_plan',
  regexp: /service plan "(.+?)"/,
  transformer: -> (name) { ServicePlan.find_by_name!(name) }
)

ParameterType(
  name: 'account_plan',
  regexp: /account plan "(.+?)"/,
  transformer: -> (name) { AccountPlan.find_by_name!(name) }
)

ParameterType(
  name: 'application_plan',
  regexp: /application plan "(.+?)"/,
  transformer: -> (name) { ApplicationPlan.find_by_name!(name) }
)

ParameterType(
  name: 'user',
  regexp: /user "([^\"]*)"/,
  transformer: -> (name) { User.find_by_username!(name) }
)

ParameterType(
  name: 'legal_terms',
  regexp: /legal terms "([^\"]*)"/,
  transformer: -> (name) { CMS::LegalTerm.find_by_title!(name) }
)

ParameterType(
  name: 'buyer_group_of_provider',
  regexp: /buyer group "([^\"]*)" of provider "([^\"]*)"/,
  transformer: -> (name, provider_name) { name }
)

ParameterType(
  name: 'email_template',
  regexp: /email template "(.+?)"/,
  transformer: -> (name) { CMS::EmailTemplate.find_by!(system_name: name) }
)


ParameterType(
  name: 'service_of_provider',
  regexp:/service "([^\"]*)" of provider "([^\"]*)"/,
  transformer: -> (service_name, provider_name) {
    Account.providers.find_by_org_name!(provider_name)
      .services.find_by_name!(service_name)
  }
)

# Finance
ParameterType(
  name: 'invoice',
  regexp: /invoice "(.+?)"/,
  transformer: -> (id) {
    Invoice.find_by_id(id) or Invoice.find_by_friendly_id(id) or raise "Couldn't find Invoice with id #{id}"
  }
)

ParameterType(
  name: 'on_off_toggle',
  regexp: /(on|off)/,
  transformer: -> (state) { state == 'on' }
)


# Authentication Providers
OAUTH_PROVIDER_OPTIONS = {
  auth0: {
    site: "https://client.auth0.com"
  },
  keycloak: {
    site: "http://localhost:8080/auth/realms/3scale"
  }
}.freeze

ParameterType(
  name: 'authentication_provider',
  regexp: /authentication provider "([^\"]+)"/,
  transformer: -> (authentication_provider_name) {
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
  }
)
