# frozen_string_literal: true

quoted_list_subpattern = '"[^"]*"(?:(?:,| and) "[^"]*")'

QUOTED_ONE_OR_MORE_PATTERN = "(#{quoted_list_subpattern}*)"
QUOTED_TWO_OR_MORE_PATTERN = "(#{quoted_list_subpattern}+)"
QUOTED_LIST_PATTERN = QUOTED_ONE_OR_MORE_PATTERN # 1 or more is the default

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
    when 'provider' then
      provider_by_name(name)
    when 'buyer' then
      Account.buyers.find_by!(name: name)
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
  name: 'prepaid_or_postpaid',
  regexp: /(prepaid|postpaid)?/,
  transformer: ->(mode = nil) { mode }
)

ParameterType(
  name: 'backend_version',
  regexp: /(?:v(\d+)|(oauth))/,
  transformer: ->(version, oauth) { version.presence || oauth.presence }
)

ParameterType(
  name: 'page',
  regexp: /page "([^"]*)"/,
  transformer: ->(title) { Page.find_by!(title: title) }
)

ParameterType(
  name: 'plan',
  regexp: /(application|account|service)?\s?plan "([^"]*)"/,
  transformer: ->(type = nil, name) do
    case type
    when 'application' then
      ApplicationPlan.find_by!(name: name)
    when 'account' then
      AccountPlan.find_by!(name: name)
    when 'service' then
      ServicePlan.find_by!(name: name)
    else
      Plan.find_by!(name: name)
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
  # TODO check this .present? condition
  transformer: ->(*args) do
    name = args.map(&:presence).compact.first
    name.present? ? provider_by_name(name) : @provider
  end
)

ParameterType(
  name: 'buyer',
  type: Account,
  regexp: /buyer "([^"]*)"/,
  transformer: ->(org_name) { Account.buyers.find_by!(org_name: org_name) }
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
  name: 'application',
  type: Cinstance,
  regexp: /application "([^"]*)"/,
  transformer: ->(name) { Cinstance.find_by!(name: name) }
)

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
  name: 'section_of_provider',
  regexp: /section "([^"]*)" of provider "([^"]*)"/,
  transformer: ->(name, provider_name) do
    provider_by_name(provider_name).provided_sections.find_by!(title: name)
  end
)

ParameterType(
  name: 'forum',
  regexp: /"([^"]*)"|the forum of "([^"]*)"/,
  transformer: ->(name, other_name) { provider_by_name(name.presence || other_name.presence).forum }
)

ParameterType(
  name: 'topic',
  regexp: /topic "([^"]*)"/,
  transformer: ->(title) { Topic.find_by!(title: title) }
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
  regexp: /legal terms "([^"]*)"/,
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
  name: 'expiration_date',
  regexp: /expiration date (\w+, *\d+|\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01]))/,
  transformer: ->(date) { Date.parse(date) }
)

ParameterType(
  name: 'enabled',
  regexp: /enabled|disabled|not enabled/,
  transformer: ->(value) { value == 'enabled' }
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
  transformer: ->(visibility) { visibility == 'public' }
)

ParameterType(
  name: 'live_or_suspended',
  regexp: /live|suspended/,
  transformer: ->(state) { state.titleize }
)

ParameterType(
  name: 'with',
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
  name: 'true',
  regexp: /true|false/,
  transformer: ->(value) { value == 'true' }
)

ParameterType(
  name: 'today',
  regexp: /today|yesterday/,
  transformer: ->(value) { value }
)

ParameterType(
  name: 'does',
  regexp: /|does|does not|doesn't/,
  transformer: ->(value) { value == 'does' || value.blank? }
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
