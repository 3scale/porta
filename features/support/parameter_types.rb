# frozen_string_literal: true

quoted_list_subpattern = '"[^"]*"(?:(?:,| and) "[^"]*")'

QUOTED_ONE_OR_MORE_PATTERN = "(#{quoted_list_subpattern}*)"
QUOTED_TWO_OR_MORE_PATTERN = "(#{quoted_list_subpattern}+)"
QUOTED_LIST_PATTERN = QUOTED_ONE_OR_MORE_PATTERN # 1 or more is the default

ParameterType(
  name: 'symbol',
  regexp: /(.+)/,
  transformer: -> { _1.to_sym }
)

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

# TODO: rename this 'account' and accept provider/buyer/account and "current account" etc.
ParameterType(
  name: 'provider_or_buyer',
  type: Account,
  regexp: /(?:the )?(provider|buyer)(?: "([^"]*)")?/,
  transformer: ->(type, name) {
    case type
    when 'provider'
      name.present? ? provider_by_name(name) : @provider.reload
    when 'buyer'
      name.present? ? Account.buyers.find_by!(name: name) : @buyer || @account
    end
  }
)

ParameterType(
  name: 'account',
  type: Account,
  regexp: /(?:provider|buyer|account) "([^"]*)"/,
  transformer: ->(org_name) { Account.find_by!(org_name: org_name) }
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
  type: String,
  regexp: /((?:the )?.*(?: page?))/,
  transformer: ->(page_name) { path_to(page_name) }
)

ParameterType(
  name: 'plan',
  type: Plan,
  regexp: /(?:(application|account|service) )?plan "(.*)"|the plan/,
  transformer: ->(type, name) do
    return @plan if name.blank?

    case type
    when 'application' then ApplicationPlan
    when 'service' then ServicePlan
    when 'account' then AccountPlan
    else Plan
    end.find_by!(name: name)
  end
)

ParameterType(
  name: 'application_plan',
  type: ApplicationPlan,
  regexp: /(?:application )?plan "(.*)"/,
  transformer: ->(name) { ApplicationPlan.find_by!(name: name) }
)

ParameterType(
  name: 'plan_type',
  regexp: /(published )?(account|service|application)/,
  transformer: ->(published, type) { "#{published} #{type} plan".parameterize.underscore }
)

ParameterType(
  name: 'authentication_strategy',
  regexp: /(Janrain|internal|Cas)/,
  transformer: ->(strategy) { strategy }
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
  name: 'backend',
  type: BackendApi,
  regexp: /the backend|backend "([^"]*)"/,
  transformer: ->(*args) do
    return BackendApi.find_by(name: args[0]) if args[0].present?

    @backend
  end
)

ParameterType(
  name: 'buyer',
  type: Account,
  regexp: /buyer "([^"]*)"|the buyer/,
  transformer: ->(org_name) do
    return Account.buyers.find_by!(org_name: org_name) if org_name.present?

    (@buyer || @account).reload
  end
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
  name: 'application',
  type: Cinstance,
  regexp: /application "([^"]*)"|the application/,
  transformer: ->(name) do
    return Cinstance.find_by!(name: name) if name.present?

    @application || @cinstance
  end
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
  name: 'change_plan_permission',
  regexp: /directly|only with credit card|by request|with credit card required/,
  transformer: ->(p) {
    include PlanHelpers # FIXME: cannot access PlanHelpers mehtod without this
    change_plan_permission_to_sym(p)
  }
)

ParameterType(
  name: 'service',
  type: Service,
  regexp: /service "([^"]*)"|the product/,
  transformer: ->(name) do
    return @product || @service if name.nil?

    Service.find_by!(name: name)
  end,
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
  name: 'public',
  regexp: /public|private|restricted/,
  transformer: ->(visibility) { visibility == 'public' }
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
  regexp: /does|does not|doesn't/,
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
  name: 'api_docs_service',
  class: ApiDocs::Service,
  regexp: /the spec|spec "(.*)"/,
  transformer: ->(name) do
    return ApiDocs::Service.find_by!(name: name) if name.present?

    @api_docs_service
  end
)

ParameterType(
  name: 'spec_version',
  regexp: /(invalid)?\s?(Swagger 1.2|Swagger 2|OAS 3.0|OAS 3.1)/,
  transformer: ->(invalid, version_name) { { version: numbered_swagger_version(version_name), invalid: invalid.present? } }
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

ParameterType(
  name: 'ordinal',
  regexp: /(\d+)(?:st|rd|nd|th)/,
  transformer: ->(value) { value.to_i }
)

ParameterType(
  name: 'count',
  regexp: /(\d+)|(one|multiple|zero)/,
  transformer: ->(number, description) {
    return number.to_i if number.present?

    case description
    when 'one' then 1
    when 'zero' then 0
    else 2 # multiple
    end
  }
)

ParameterType(
  name: 'amount',
  regexp: /(a|an|no|\d+)/,
  transformer: ->(value) do
    return 1 if value == 'a'

    parse_email_count(value) # https://github.com/email-spec/email-spec/blob/b8d22b4d1e347fd913a7602ea01ecaed827c7ca9/lib/email_spec/helpers.rb#L160
  end
)

ParameterType(
  name: 'field_definition_target',
  regexp: /(applications|users|accounts)/,
  transformer: ->(value) do
    {
      'applications' => 'Cinstance',
      'users' => 'User',
      'accounts' => 'Account',
    }[value]
  end
)

ParameterType(
  name: 'css_selector',
  regexp: /(.*)/,
  transformer: ->(selector) { selector_for(selector) }
)

ParameterType(
  name: 'read_only_status',
  regexp: /(editable|read only)/,
  transformer: ->(value) do
    {
      'editable' => false,
      'read only' => true,
    }[value]
  end
)

ParameterType(
  name: 'alert_type',
  regexp: /|default|info|success|warning|danger/,
  transformer: ->(type) { type || 'default' }
)
