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
  regexp: /(?:(provider|buyer) "([^"]*)"|the provider)/,
  transformer: ->(type, name) {
    case type
    when 'provider'
      provider_by_name(name)
    when 'buyer'
      Account.buyers.find_by!(name: name)
    else
      @provider
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
  name: 'billing_mode',
  regexp: /(prepaid|postpaid|)/,
  transformer: ->(mode) {
    if mode == 'prepaid'
      'Finance::PrepaidBillingStrategy'
    else
      'Finance::PostpaidBillingStrategy'
    end
  }
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
  transformer: ->(type) { "#{type}_plan" }
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
  regexp: /the provider|provider "([^"]*)"|((?:the )?master )?provider/,
  transformer: ->(*args) do
    return provider_by_name('master') if args[1].present?

    name = args[0].presence
    name ? provider_by_name(name) : @provider
  end
)

ParameterType(
  name: 'product',
  type: Service,
  regexp: /the product|product "([^"]*)"/,
  transformer: ->(*args) do
    return Service.find_by(name: args[0]) if args[0].present?

    @product || @service || @provider.default_service
  end
)

ParameterType(
  name: 'buyer',
  type: Account,
  regexp: /buyer "([^"]*)"|the buyer/,
  transformer: ->(org_name) { org_name.present? ? Account.buyers.find_by!(org_name: org_name) : @buyer }
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
  regexp: /application "([^"]*)"|the application/,
  transformer: ->(name) { name.present? ? Cinstance.find_by!(name: name) : @application || @cinstance }
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
  transformer: ->(name) { find_metric(Metric.where(parent_id: nil), name) }
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
  regexp: /method "([^"]*)"/,
  transformer: ->(name) { find_metric(Metric.where.not(parent_id: nil), name) }
)

def find_metric(metrics, name)
  metric = metrics.find_by(friendly_name: name) || metrics.find_by(system_name: name)

  metric or raise ActiveRecord::RecordNotFound, "Couldn't find metric '#{name}'"
end

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
  regexp: /user "([^"]*)"|the user/,
  transformer: ->(name) { name.present? ? User.find_by!(username: name) : @user }
)

ParameterType(
  name: 'legal_terms',
  regexp: /legal terms "([^"]*)"/,
  transformer: ->(name) { CMS::LegalTerm.find_by!(title: name) }
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
  name: 'payment_gateway',
  regexp: /braintree|stripe/,
  transformer: ->(value) {
    case value
    when 'braintree' then :braintree_blue
    when 'stripe' then :stripe
    end
  }
)

ParameterType(
  name: 'enabled',
  regexp: /enabled|disabled|not enabled/,
  transformer: ->(value) { value == 'enabled' }
)

ParameterType(
  name: 'enable',
  regexp: /enable|disable/,
  transformer: ->(value) { value == 'enable' }
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
  name: 'enabled_or_disabled', # TODO: use type 'enabled'
  regexp: /enabled|disabled/,
  transformer: ->(value) { value }
)

ParameterType(
  name: 'is',
  regexp: /is|is not/,
  transformer: ->(value) { value == 'is' }
)

ParameterType(
  name: 'will',
  regexp: /will|will not|won't/,
  transformer: ->(value) { value == 'will' }
)

ParameterType(
  name: 'should',
  regexp: /should|should not|shouldn't/,
  transformer: ->(value) { value == 'should' }
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
  name: 'date',
  regexp: /(\w{3,}( \d{2,}?)?, \d{4})/,
  transformer: ->(date) { Date.parse(date) }
)

ParameterType(
  name: 'switch',
  regexp: /"(.+?)"(?: switch)?/,
  transformer: ->(name) { name }
)

ParameterType(
  name: 'spec_version',
  regexp: /Swagger 1.2|Swagger 2|OAS 3.0/,
  transformer: ->(version) do
    {
      'Swagger 1.2' => '1.2',
      'Swagger 2' => '2.0',
      'OAS 3.0' => '3.0'
    }[version]
  end
)

ParameterType(
  name: 'valid',
  regexp: /valid|invalid/,
  transformer: ->(value) { value == 'valid' }
)

ParameterType(
  name: 'has',
  regexp: /has|has already|does not have|has not|has not yet|don't have/,
  transformer: ->(value) { ['has', 'has already'].include?(value) }
)

ParameterType(
  name: 'can',
  regexp: /can|can't|cannot/,
  transformer: ->(value) { value == 'can' }
)
