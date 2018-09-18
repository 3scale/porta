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

  [
    Liquid::Tags::IncludeWithComments,
    Liquid::Tags::AuthorizeNetForm,
    Liquid::Tags::PaymentExpressForm,
    Liquid::Tags::OgoneForm,
    Liquid::Tags::BraintreeCustomerForm,
    Liquid::Tags::StripeForm,
    Liquid::Tags::Adyen12Form,
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
  ].each do |tag_class|
    ::Liquid::Template.register_tag(tag_class.tag, tag_class)
  end

  Liquid::XssProtection.enable!
  # Xss protection can be enabled by passing :html_escape to registers when rendering

  ActionView::Template.register_template_handler :liquid, Liquid::Template::Handler
end
