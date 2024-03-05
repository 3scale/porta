# frozen_string_literal: true
require 'liquid'
require 'liquid/url_helper_hacks'


# allow calling present? in {% if %}
Liquid::Expression::LITERALS['present'] = :present?

Rails.application.config.to_prepare do
  # Hacks
  ActionView::Helpers.send(:include, Liquid::UrlHelperHacks)

  [
    Liquid::Filters::GoogleAnalytics,
    Liquid::Filters::ParamFilter,
    Liquid::Filters::RailsHelpers,
    Liquid::Filters::FormHelpers,
    Liquid::Filters::UrlHelpers,
  ].each do |klass|
    Liquid::Template.register_filter(klass)
  end

  tags = [
    Liquid::Tags::IncludeWithComments,
    Liquid::Tags::PaymentExpressForm,
    Liquid::Tags::BraintreeCustomerForm,
    Liquid::Tags::StripeForm,
    Liquid::Tags::Content,
    Liquid::Tags::Container,
    Liquid::Tags::CreditCardMissing,
    Liquid::Tags::EssentialAssets,
    Liquid::Tags::Flash,
    Liquid::Tags::Footer,
    Liquid::Tags::Oldfooter,
    Liquid::Tags::Form,
    Liquid::Tags::InternalError,
    Liquid::Tags::LatestForumPosts,
    Liquid::Tags::LatestMessages,
    Liquid::Tags::Logo,
    Liquid::Tags::Menu,
    Liquid::Tags::Submenu,
    Liquid::Tags::ThemeStylesheet,
    Liquid::Tags::UserWidget,
    Liquid::Tags::PlanWidget,
    Liquid::Tags::PageSection,
    Liquid::Tags::PageSubSection,
    Liquid::Tags::TrialNotice,
    Liquid::Tags::Email,
    Liquid::Tags::Debug,
    Liquid::Tags::CSRF,
    Liquid::Tags::ThreeScaleEssentials,
    Liquid::Tags::Portlet,
    Liquid::Tags::ActiveDocs,
    Liquid::Tags::ContentFor,
    Liquid::Tags::SortLink,
    Liquid::Tags::CdnAsset,
    Liquid::Tags::DisableClientCache,
  ]

  # These tags no longer exist in then codebase but they need to be registered for backwards
  # compatibility with outdated customers' dev portal templates. If they are not, any existing
  # template or parital referencing them will break
  # For instance, payment_gateways/show.html.liquid will throw an error if it has:
  #
  #  {% if provider.payment_gateway.type == "authorize_net" %}
  #    {% if current_account.credit_card_stored? %}
  #      {% authorize_net_form "Edit Credit Card Details" %}
  #    {% else %}
  #      {% authorize_net_form "Add Credit Card Details" %}
  #    {% endif %}
  #  {% endif }
  #
  # Even if the condition is never met and the method #authorize_net_form is never called. This
  # happens because Liquid evaluates the whole templates before rendering them.
  removed_tags = [
    Liquid::Tags::AuthorizeNetForm,
    Liquid::Tags::OgoneForm,
  ]

  tags.concat(removed_tags)
    .each do |tag_class|
      ::Liquid::Template.register_tag(tag_class.tag, tag_class)
    end

  Liquid::XssProtection.enable!
  # Xss protection can be enabled by passing :html_escape to registers when rendering

  ActionView::Template.register_template_handler :liquid, Liquid::Template::Handler
end
