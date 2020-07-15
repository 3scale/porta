# frozen_string_literal: true

class AccountRepresenter < ThreeScale::Representer
  include ThreeScale::JSONRepresenter
  include Roar::XML

  # include FieldsRepresenter
  # include ExtraFieldsRepresenter

  wraps_resource :account

  property :id
  property :created_at
  property :updated_at

  with_options(if: :scheduled_for_deletion?) do
    property :deletion_date
  end

  with_options(if: ->(*) { provider? }) do
    property :admin_domain
    property :domain
    property :admin_base_url
    property :base_url
    property :from_email
    property :support_email
    property :finance_support_email
    property :site_access_code
  end

  with_options(unless: ->(*) { destroyed? }) do
    property :credit_card_stored, exec_context: :decorator
    #
    # TODO: this stuff is in #to_xml, should it be moved here and if so, should we remove links?
    #
    # collection :plans, extend: PlanRepresenter
    # collection :users, extend: UserRepresenter
    #
    #
    # TODO: this one needs to have option passed like in
    #   https://github.com/3scale/system/blob/master/app/representers/cms/page_representer.rb#L8
    #
    # if options[:with_apps]
    #  bought_cinstances.to_xml(:builder => xml, :root => 'applications')
    # end

    property :monthly_billing_enabled,  exec_context: :decorator
    property :monthly_charging_enabled, exec_context: :decorator

    # property :admin_user_display_name

    with_options(if: ->(*) { credit_card_stored? }) do
      property :credit_card_partial_number
      property :credit_card_expires_on
    end
  end

  property :state

  link :self do
    admin_api_account_url(self) unless represented.provider?
  end

  link :users do
    admin_api_account_users_url(self)
  end

  def credit_card_stored
    represented.credit_card_stored?
  end

  delegate :monthly_charging_enabled, :monthly_billing_enabled, to: :settings, allow_nil: true
  # delegate :settings, to: :represented

  def settings
    represented.settings
  end
end
