# frozen_string_literal: true

# TODO: double check which parameterTypes are not used and remove them

quoted_list_subpattern = '"[^"]*"(?:(?:,| and) "[^"]*")'

QUOTED_ONE_OR_MORE_PATTERN = "(#{quoted_list_subpattern}*)"
QUOTED_TWO_OR_MORE_PATTERN = "(#{quoted_list_subpattern}+)"
QUOTED_LIST_PATTERN        = QUOTED_ONE_OR_MORE_PATTERN # 1 or more is the default

ParameterType(
  name: 'list_of_strings',
  regexp: /(?:"[^"]*"(?: |, | and ))*"[^"]*"/,
  transformer: ->(list) { list.from_sentence.map { |item| item.delete('"') } }
)

ParameterType(
  name: 'list_of_2_plus_strings',
  regexp: /(?:"[^"]*"(?: |, | and ))+"[^"]*"/,
  transformer: ->(list) { list.from_sentence.map { |item| item.delete('"') } }
)

ParameterType(
  name: 'provider_or_buyer',
  regexp: /(provider|buyer) "([^"]*)"/,
  transformer: ->(type, name) {
    case type
    when 'provider' then provider_by_name(name)
    when 'buyer' then Account.buyers.find_by!(name: name)
    end
  }
)

ParameterType(
  name: 'provider_or_service',
  regexp: /(provider|service) "([^"]*)"/,
  transformer: ->(type, name) {
    case type
    when 'provider' then provider_by_name(name)
    when 'service' then Service.find_by!(name: name)
    end
  }
)

def provider_by_name(name)
  # TODO: fix this hacky way of getting master
  if name == 'master'
    begin
      Account.master
    rescue
      FactoryBot.create(:master_account)
    end
  else
    Account.providers.readonly(false).find_by!(org_name: name)
  end
end

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
  name: 'prepaid_or_postpaid',
  regexp: /(prepaid|postpaid)?/,
  transformer: ->(mode = nil) { mode }
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
  regexp: /page "([^"]*)"/,
  transformer: ->(title) { Page.find_by!(title: title) }
)

ParameterType(
  name: 'time_period',
  regexp: /(second|minute|hour|day|week|month|year)s?/,
  transformer: ->(period) { period.to_sym }
)

ParameterType(
  name: 'regexp',
  regexp: %r{/([^/]*)/},
  transformer: ->(r) { Regexp.new(regexp, Regexp::IGNORECASE) }
)

ParameterType(
  name: 'page_number',
  regexp: /(d+)st|nd|rd|th page/,
  transformer: ->(int) { int }
)

# FIXME: regexp too complex?
ParameterType(
  name: 'link_to_page',
  regexp: /(the .+page.*)|(my .*page)|(the provider dashboard)|(my invoices)/,
  # regexp: /(the.+page(?: for ".+")*(?: (?:of|for) service ".+")*(?: of provider ".+")*)|(the provider dashboard)/,
  transformer: ->(page_name) {
    # FIXME: it should transform the page_name into a path, but @provider is nil
    # PathsHelper::PathFinder.new(@provider).path_to(page_name)
    page_name
  }
)

ParameterType(
  name: 'plan',
  regexp: /(application|account|service)?\s?plan "([^"]*)"/,
  transformer: ->(type = nil, name) do
    case type
    when 'application' then ApplicationPlan.find_by!(name: name)
    when 'account' then AccountPlan.find_by!(name: name)
    when 'service' then ServicePlan.find_by!(name: name)
    else Plan.find_by!(name: name)
    end
  end
)

ParameterType(
  name: 'service_plan',
  regexp: /service plan "([^"]*)"/,
  transformer: ->(name) { ServicePlan.find_by!(name: name) }
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

ParameterType(
  name: 'account',
  type: Account,
  regexp: /provider|buyer|account "([^"]*)"/,
  transformer: ->(org_name) { Account.find_by!(org_name: org_name) }
)

ParameterType(
  name: 'provider',
  type: Account,
  regexp: /provider "([^"]*)"|(master) provider|provider (master)/,
  # FIXME: This alternative regexp would be useful but "@provider" is not accessible from the transformer
  # regexp: /provider "([^"]*)"|(master) provider|provider (master)|the provider/,
  transformer: ->(name) { name.present? ? provider_by_name(name) : @provider }
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
  regexp: /active|pending|approved|rejected|accepted|suspended/,
  transformer: ->(state) { state }
)

ParameterType(
  name: 'account_type',
  regexp: /provider|buyer|master/,
  transformer: ->(state) { state }
)

ParameterType(
  name: 'the_user_key_of_buyer',
  regexp: /the user key of buyer "([^"]*)"/,
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

ParameterType(
  name: 'page of provider',
  regexp: /^page "([^"]*)" of provider "([^"]*)"$/,
  transformer: ->(title, provider_name) do
    provider = providerl(org_name)
    Page.find_by!(title: title, account_id: provider.id)
  end
)

ParameterType(
  name: 'page at of provider',
  regexp: /^page at (.*) of provider "([^"]*)"$/,
  transformer: ->(path, provider_name) do
    provider = providerl(org_name)
    Page.find_by!(path: path, account_id: provider.id)
  end
)

ParameterType(
  name: 'section_of_provider',
  regexp: /section "([^"]*)" of provider "([^"]*)"/,
  transformer: ->(name, provider_name) do
    provider_by_name(provider_name).provided_sections.find_by!(title: name)
  end
)

ParameterType(
  name: 'html block',
  regexp: /^html block "([^"]*)"$/,
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
  regexp: /"([^"]*)"|the forum of "([^"]*)"/,
  transformer: ->(name) { provider_by_name(name).forum }
)

ParameterType(
  name: 'topic',
  regexp: /topic "([^"]*)"/,
  transformer: ->(title) { Topic.find_by!(title: title) }
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
  name: 'plan_permission',
  regexp: /directly|only with credit card|by request|with credit card required/,
  transformer: ->(p) {
    include PlanHelpers # FIXME: cannot access PlanHelpers mehtod without this
    change_plan_permission_to_sym(p)
  }
)

ParameterType(
  name: 'service',
  type: Service,
  regexp: /service "([^"]*)"/,
  transformer: ->(name) { Service.find_by!(name: name) },
  prefer_for_regexp_match: true
)

ParameterType(
  name: 'user',
  type: User,
  regexp: /user "([^"]*)"/,
  transformer: ->(name) { User.find_by!(username: name) }
)

ParameterType(
  name: 'legal_terms',
  regexp: /legal terms "[^"]*"/,
  transformer: ->(name) { CMS::LegalTerm.find_by!(title: name) }
)

ParameterType(
  name: 'buyer_group_of_provider',
  regexp: /buyer group "([^"]*)" of provider "([^"]*)"/,
  transformer: ->(name, provider_name) { name }
)

ParameterType(
  name: 'service_of_provider',
  regexp: /service "([^"]*)" of provider "([^"]*)"/,
  transformer: ->(service_name, provider_name) do
    provider_by_name(provider_name).services
                                   .find_by!(name: service_name)
  end
)

ParameterType(
  name: 'email_template',
  regexp: /email template "(.+?)"/,
  transformer: ->(name) { CMS::EmailTemplate.find_by!(system_name: name) }
)

ParameterType(
  name: 'invoice',
  regexp: /^invoice "(.+?)"$/,
  transformer: ->(service_name, provider_name) { Invoice.find_by(id: id) or Invoice.find_by(friendly_id: id) or raise "Couldn't find Invoice with id #{id}" }
)

OAUTH_PROVIDER_OPTIONS = {
  auth0: {
    site: "https://client.auth0.com"
  },
  keycloak: {
    site: "http://localhost:8080/auth/realms/3scale"
  }
}.freeze

ParameterType(
  name: 'date',
  regexp: /(.*)/,
  transformer: ->(date) { Date.parse(date) }
)

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
  regexp: /published|hidden|/,
  transformer: ->(value) { value == 'published' }
)

ParameterType(
  name: 'public',
  regexp: /public|private|restricted/,
  transformer: ->(visibility) { visibility == 'public'}
)

ParameterType(
  name: 'live_or_suspended',
  regexp: /live|suspended/,
  transformer: ->(state) { state.titleize }
)

ParameterType(
  name: 'with_or_without',
  regexp: /with|without/,
  transformer: ->(value) { value == 'with' }
)

ParameterType(
  name: 'visible_or_hidden',
  regexp: /visible|hidden/,
  transformer: ->(value) { value }
)

ParameterType(
  name: 'enabled_or_disabled',
  regexp: /enabled|disabled/,
  transformer: ->(value) { value }
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
  name: 'true_or_false',
  regexp: /true|false/,
  transformer: ->(value) { value == 'true' }
)

ParameterType(
  name: 'today_or_yesterday',
  regexp: /today|yesterday/,
  transformer: ->(value) { value }
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

ParameterType(
  name: 'does',
  regexp: /|does|does not|doesn't/,
  transformer: ->(value) { value == 'does' || value.blank? }
)

ParameterType(
  name: 'strings',
  regexp: /"(.+?)"/,
  transformer: ->(name) { name.from_sentence.map { |n| n.delete('"') } }
)

ParameterType(
  name: 'month',
  regexp: /\w+, *\d+/,
  transformer: ->(date) { date }
)

ParameterType(
  name: 'switch',
  regexp: /"(.+?)"(?: switch)?/,
  transformer: ->(name) { name }
)
