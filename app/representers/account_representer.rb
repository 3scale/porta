# frozen_string_literal: true

module AccountRepresenter
  include ThreeScale::JSONRepresenter
  include FieldsRepresenter
  include ExtraFieldsRepresenter

  wraps_resource

  with_options(unless: ->(*) { new_record? }) do
    property :id
    property :created_at
    property :updated_at
  end

  with_options(if: :scheduled_for_deletion?) do |account|
    account.property :deletion_date
  end

  with_options(if: ->(*) { provider? }) do
    property :admin_domain
    property :domain
    property :from_email
    property :support_email
    property :finance_support_email
    property :site_access_code
  end

  with_options(unless: ->(*) { destroyed? }) do
    property :credit_card_stored
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

    property :monthly_billing_enabled
    property :monthly_charging_enabled

    with_options(if: ->(*) { credit_card_stored? }) do
      property :credit_card_partial_number
      property :credit_card_expires_on
    end
  end

  property :state

  link :self do
    admin_api_account_url(self) unless provider?
  end

  link :users do
    admin_api_account_users_url(self)
  end

  def credit_card_stored
    credit_card_stored?
  end

  delegate :monthly_charging_enabled, to: :settings
  delegate :monthly_billing_enabled, to: :settings
end
