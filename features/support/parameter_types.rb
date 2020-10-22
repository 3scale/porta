# frozen_string_literal: true

quoted_list_subpattern = '"[^"]*"(?:(?:,| and) "[^"]*")'

QUOTED_ONE_OR_MORE_PATTERN = "(#{quoted_list_subpattern}*)"
QUOTED_TWO_OR_MORE_PATTERN = "(#{quoted_list_subpattern}+)"
QUOTED_LIST_PATTERN        = QUOTED_ONE_OR_MORE_PATTERN # 1 or more is the default

ParameterType(
  name: 'provider_or_buyer',
  regexp: /(?:provider|buyer) {string}/,
  transformer: ->(type, name) {
    if type == 'provider'
      Provider.find_by!(name: name)
    else
      Buyer.find_by!(name: name)
    end
  }
)

ParameterType(
  name: 'amount',
  regexp: /(a|an|no|\d+)/,
  transformer: ->(amount) {
    # From: EmailSpec::Helpers.parse_email_count
    case amount
    when 'no'
      0
    when 'an', 'a'
      1
    else
      amount.to_i
    end
  }
)

ParameterType(
  name: 'billing',
  regexp: /(prepaid|postpaid)? ?billing/,
  transformer: ->(mode) do
    if mode && mode == 'prepaid'
      'Finance::PrepaidBillingStrategy'
    else
      'Finance::PostpaidBillingStrategy'
    end
  end
)

ParameterType(
  name: 'list',
  regexp: /^#{QUOTED_LIST_PATTERN}$/,
  transformer: ->(list) { list.from_sentence.map { |item| item.delete('"') } }
)

ParameterType(
  name: 'backend_version',
  regexp: /(?:v(\d+)|(oauth))/,
  transformer: ->(version) { version }
)

ParameterType(
  name: 'page',
  regexp: /page "([^\"]*)"/,
  transformer: ->(title) { Page.find_by!(title: title) }
)

ParameterType(
  name: 'time_period',
  regexp: /(second|minute|hour|day|week|month|year)s?/,
  transformer: ->(period) { period.to_sym }
)

ParameterType(
  name: 'regexp',
  regexp: %r{\/([^\/]*)\/},
  transformer: ->(r) { Regexp.new(regexp, Regexp::IGNORECASE) }
)

ParameterType(
  name: 'link_to_page',
  regexp: /(.+)|link to (.+)/,
  transformer: ->(page_name) { PathsHelper::PathFinder.new(@provider).path_to(page_name) }
)

# Plans

ParameterType(
  name: 'plan_with_type', #TODO: rename
  regexp: /((?:application|account|service) plan "[^"]*")/,
  transformer: ->(type, name) do
    case type
    when 'application' then ApplicationPlan.find_by!(name: name)
    when 'account' then AccountPlan.find_by!(name: name)
    when 'service' then ServicePlan.find_by!(name: name)
    end
  end
)

ParameterType(
  name: 'plan_type',
  regexp: /account|service|application/,
  transformer: ->(type) { type }
)

ParameterType(
  name: 'authentication_strategy',
  regexp: /(Janrain|internal|Cas)/,
  transformer: ->(strategy) { strategy }
)

# Accounts

ParameterType(
  name: 'account',
  type: Account,
  regexp: /account "([^"]*)"/,
  transformer: ->(org_name) { Account.find_by!(org_name: org_name) }
)

ParameterType(
  name: 'the_provider',
  type: Account,
  regexp: /^the provider$/,
  transformer: ->(_) { @provider or raise ActiveRecord::RecordNotFound, "@provider does not exist" }
)

ParameterType(
  name: 'provider',
  type: Account,
  regexp: /provider "([^"]*)"|(master) provider|provider (master)|(the provider)/,
  transformer: ->(name) do
    # TODO: fix this hacky way of getting master
    if name == 'master'
      begin
        Account.master
      rescue
        FactoryBot.create(:master_account)
      end
    else
      name = @provider.domain if name == 'the provider'
      Account.providers.readonly(false).find_by!(org_name: name)
    end
  end
)

ParameterType(
  name: 'master_provider',
  type: Account,
  regexp: /^(master provider)$/,
  transformer: ->(_) { Account.master }
)

ParameterType(
  name: 'buyer',
  type: Account,
  regexp: /buyer "([^"]*)"/,
  transformer: ->(org_name) { Account.buyers.find_by!(org_name: org_name) }
)

ParameterType(
  name: 'status',
  regexp: /denied|allowed|hidden|visible/,
  transformer: ->(status) { status }
)

ParameterType(
  name: 'state',
  regexp: /active|pending|approved|rejected|accepted/,
  transformer: ->(state) { state }
)

# Cinstance / Application

ParameterType(
  name: 'user_key_of_buyer',
  regexp: /^user key of buyer "([^"]*)"$/,
  transformer: ->(name) { Account.buyers.find_by!(org_name: name).bought_cinstance.user_key }
)

ParameterType(
  name: 'the application id of buyer',
  regexp: /^the application id of buyer "([^"]*)"$/,
  transformer: ->(name) { Account.buyers.find_by!(org_name: name).bought_cinstance.application_id }
)

ParameterType(
  name: 'application',
  type: Cinstance,
  regexp: /application "([^"]*)"/,
  transformer: ->(name) { Cinstance.find_by!(name: name) }
)

# Potato CMS

ParameterType(
  name: 'cms_page',
  type: CMS::Page,
  regexp: /CMS Page "(.+?)"/,
  transformer: ->(path) { CMS::Page.find_by!(path: path) }
)

ParameterType(
  name: 'cms_partial',
  type: CMS::Partial,
  regexp: /CMS Partial "(.+?)"/,
  transformer: ->(path) { CMS::Partial.find_by!(system_name: path) }
)

# CMS

ParameterType(
  name: 'page of provider',
  regexp: /^page "([^\"]*)" of provider "([^\"]*)"$/,
  transformer: ->(title, provider_name) do
    provider = Account.providers.find_by!(org_name: provider_name)
    Page.find_by!(title: title, account_id: provider.id)
  end
)

ParameterType(
  name: 'page at of provider',
  regexp: /^page at (.*) of provider "([^\"]*)"$/,
  transformer: ->(path, provider_name) do
    provider = Account.providers.find_by!(org_name: provider_name)
    Page.find_by!(path: path, account_id: provider.id)
  end
)

ParameterType(
  name: 'section_of_provider',
  regexp: /section "([^\"]*)" of provider "([^\"]*)"/,
  transformer: ->(name, provider_name) do
    provider = Account.providers.readonly(false).find_by!(org_name: provider_name)
    provider.provided_sections.find_by!(title: name)
  end
)

ParameterType(
  name: 'html block',
  regexp: /^html block "([^\"]*)"$/,
  transformer: ->(name) { HtmlBlock.find_by!(name: name) }
)

ParameterType(
  name: 'country',
  regexp: /^country "([^"]*)"$/,
  transformer: ->(name) { Country.find_by!(name: name) }
)

ParameterType(
  name: 'feature',
  regexp: /^feature "([^"]*)"$/,
  transformer: ->(name) { Feature.find_by!(name: name) }
)

# Forum

ParameterType(
  name: 'forum',
  regexp: /"([^"]*)"|the forum of "[^\"]*"/,
  transformer: ->(name) { Account.providers.find_by!(org_name: name).forum }
)

ParameterType(
  name: 'topic',
  regexp: /^topic "([^\"]+)"$/,
  transformer: ->(name) { Topic.find_by!(title: title) }
)

ParameterType(
  name: 'post',
  regexp: /^post "([^"]*)"$/,
  transformer: ->(body) do
    post = Post.all.to_a.find { |p| p.body == body }
    assert post
    post
  end
)

ParameterType(
  name: 'the_last_post_under_topic',
  regexp: /the last post under topic "([^"]*)"/,
  transformer: ->(title) { Topic.find_by!(title: title).posts.last }
)

ParameterType(
  name: 'category',
  regexp: /^category "([^"]*)"$/,
  transformer: ->(name) { TopicCategory.find_by!(name: name) }
)

# Metric

ParameterType(
  name: 'metric',
  regexp: /metric "([^"]*)"/,
  transformer: ->(name) { Metric.find_by!(system_name: name) }
)

ParameterType(
  name: 'metric_on_application_plan',
  regexp: /metric "([^"]*)" on application plan "([^"]*)"/,
  transformer: ->(metric_name, plan_name) do
    plan = ApplicationPlan.find_by!(name: plan_name)
    plan.metrics.find_by!(system_name: metric_name)
  end
)

ParameterType(
  name: 'metric of provider',
  regexp: /^metric "([^"]*)" of provider "([^"]*)$/,
  transformer: ->(metric_name, provider_name) do
    provider = Account.find_by!(org_name: provider_name)
    provider.first_service!.metrics.find_by!(system_name: name)
  end
)

ParameterType(
  name: 'method',
  regexp: /^method "([^"]*)"$/,
  transformer: ->(name) { current_account.first_service!.metrics.hits.children.find_by!(system_name: name) }
)

ParameterType(
  name: 'plan',
  type: Plan,
  regexp: /plan "([^"]*)"/,
  transformer: ->(name) { Plan.find_by!(name: name) }
)

ParameterType(
  name: 'plan_permission',
  regexp: /directly|only with credit card|by request|with credit card required/,
  transformer: ->(p) { change_plan_permission_to_sym(p) }
)

ParameterType(
  name: 'service',
  type: Service,
  regexp: /service "([^"]*)"/,
  transformer: ->(name) { Service.find_by!(name: name) }
)

ParameterType(
  name: 'user',
  type: User,
  regexp: /user "([^"]*)"/,
  transformer: ->(name) { User.find_by!(username: name) }
)

ParameterType(
  name: 'user_type',
  regexp: /(user|pending user|active user|active admin)/,
  transformer: ->(type) {
    case type
    when 'user'
      :user
    when 'pending user'
      :pending_user
    when 'active user'
      :active_user
    when 'active admin'
      :active_admin
    end
  }
)

ParameterType(
  name: 'legal_terms',
  regexp: /legal terms "[^"]*"/,
  transformer: ->(name) { CMS::LegalTerm.find_by!(title: name) }
)

ParameterType(
  name: 'group_of',
  regexp: /buyer group "[^"]*" of provider "[^\"]*"/,
  transformer: ->(name, provider_name) { name }
)

ParameterType(
  name: 'table: buyer, name, plans',
  regexp: /^table:buyer,name,plan$/i,
  transformer: ->(table) do
    table.map_headers! {|header| header.parameterize.underscore.downcase.to_s }
    table.map_column!(:buyer) {|buyer| Account.buyers.find_by!(org_name: buyer) }
    table.map_column!(:plan) {|plan| ApplicationPlan.find_by!(name: plan) }
    table
  end
)

ParameterType(
  name: 'table: name, cost per month, setup fee',
  regexp: /^table:name,cost per month,setup fee$/i,
  transformer: ->(table) do
    table.map_headers! {|header| header.parameterize.underscore.downcase.to_s }
    table.map_column!(:cost_per_month) &:to_f
    table.map_column!(:setup_fee) &:to_f
    table
  end
)

ParameterType(
  name: 'table: code, name',
  regexp: /^table:code,name$/i,
  transformer: ->(table) do
    table.map_headers! {|header| header.parameterize.underscore.downcase.to_s }
    table
  end
)

ParameterType(
  name: 'service_of_provider',
  regexp: /service "([^\"]*)" of provider "([^\"]*)"/,
  transformer: ->(service_name, provider_name) do
    provider = Account.providers.find_by!(org_name: provider_name)
    provider.services.find_by!(name: service_name)
  end
)

# Emails

ParameterType(
  name: 'email_address',
  regexp: /(?:I|they|{string})/,
  transformer: ->(address) { address }
)

ParameterType(
  name: 'email_template',
  regexp: /email template "(.+?)"$/,
  transformer: ->(name) { CMS::EmailTemplate.find_by!(system_name: name) }
)

# Finance

ParameterType(
  name: 'invoice',
  regexp: /^invoice "(.+?)"$/,
  transformer: ->(service_name, provider_name) { Invoice.find_by(id: id) or Invoice.find_by(friendly_id: id) or raise "Couldn't find Invoice with id #{id}" }
)

ParameterType(
  name: 'balance',
  regexp: /no money|lots of money/,
  transformer: ->(balance) { balance == 'no money' ? '2' : '1' }
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
  regexp: /^authentication provider "([^\"]+)"$/,
  transformer: ->(authentication_provider_name) do
    authentication_provider = @provider.authentication_providers.find_by(name: authentication_provider_name)
    return authentication_provider if authentication_provider

    ap_underscored_name = authentication_provider_name.underscore
    options = OAUTH_PROVIDER_OPTIONS[ap_underscored_name.to_sym]
                .merge({ system_name: "#{ap_underscored_name}_hex",
                         client_id: 'CLIENT_ID',
                         client_secret: 'CLIENT_SECRET',
                         kind: ap_underscored_name,
                         name: authentication_provider_name,
                         account_id: @provider.id,
                         identifier_key: 'id',
                         username_key: 'login',
                         trust_email: false })

    authentication_provider_class = "AuthenticationProvider::#{authentication_provider_name}".constantize
    authentication_provider_class.create(options)
  end
)

# Boolean-like

ParameterType(
  name: 'enabled',
  regexp: /enabled|disabled|not enabled/,
  transformer: ->(value) { value == 'enabled' }
)

ParameterType(
  name: 'activated',
  regexp: /activated|deactivated/,
  transformer: ->(value) { value == 'activated' }
)

ParameterType(
  name: 'default',
  regexp: /default|not default|/,
  transformer: ->(value) { value == 'default' }
)

ParameterType(
  name: 'published',
  regexp: /published|hidden/,
  transformer: ->(value) { value == 'published' }
)

ParameterType(
  name: 'public',
  regexp: /public|private|restricted/,
  transformer: ->(visibility) { visibility == 'public'}
)

ParameterType(
  name: 'live_state',
  regexp: /live|suspended/,
  transformer: ->(state) { state.titleize }
)

ParameterType(
  name: 'with',
  regexp: /with|without/,
  transformer: ->(value) { value == 'with' }
)

ParameterType(
  name: 'visible',
  regexp: /visible|hidden/,
  transformer: ->(value) { value == 'visible' }
)

ParameterType(
  name: 'is',
  regexp: /is|is not/,
  transformer: ->(value) { value == 'is' }
)

ParameterType(
  name: 'are',
  regexp: /are|are not/,
  transformer: ->(value) { value == 'are' }
)

ParameterType(
  name: 'check',
  regexp: /check|uncheck/,
  transformer: ->(value) { value == 'check' }
)

ParameterType(
  name: 'checked',
  regexp: /checked|unchecked/,
  transformer: ->(value) { value == 'checked' }
)

ParameterType(
  name: 'set',
  regexp: /set|unset/,
  transformer: ->(value) { value == 'set' }
)

ParameterType(
  name: 'should',
  regexp: /should|should't|should not/,
  transformer: ->(value) { value == 'should' }
)

ParameterType(
  name: 'valid',
  regexp: /valid|invalid/,
  transformer: ->(value) { value == 'valid' }
)

ParameterType(
  name: 'on_off',
  regexp: /(on|off)/,
  transformer: ->(state) { state == 'on' }
)
