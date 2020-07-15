# frozen_string_literal: true

class AccountRepresenter < ThreeScale::Representer
  include FieldsRepresenter
  include ExtraFieldsRepresenter

  wraps_resource :account

  property :id
  property :org_name
  property :created_at, exec_context: :decorator
  property :updated_at, exec_context: :decorator

  with_options(if: ->(*) { represented.scheduled_for_deletion? }) do
    property :deletion_date, exec_context: :decorator
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
    property :credit_card_stored?, as: :credit_card_stored
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

    property :monthly_billing_enabled, exec_context: :decorator
    property :monthly_charging_enabled, exec_context: :decorator

    with_options(if: ->(*) { credit_card_stored? }) do
      property :credit_card_partial_number
      property :credit_card_expires_on
    end
  end

  property :state

  delegate :monthly_charging_enabled, :monthly_billing_enabled, to: :settings, allow_nil: true
  delegate :settings, to: :represented

  def deletion_date
    # TODO: DRY
    represented.deletion_date.to_s(:iso8601)
  end

  def created_at
    # TODO: DRY
    represented.created_at.to_s(:iso8601)
  end

  def updated_at
    # TODO: DRY
    represented.updated_at.to_s(:iso8601)
  end

  class JSON < AccountRepresenter
    include Roar::JSON
    # include ThreeScale::JSONRepresenter

    wraps_resource :account

    link :self do
      admin_api_account_url(represented) unless represented.provider?
    end

    link :users do
      admin_api_account_users_url(represented)
    end
  end

  class XML < AccountRepresenter
    include Roar::XML

    wraps_resource :account

    link :self do
      admin_api_account_url(represented) unless represented.provider?
    end

    link :users do
      admin_api_account_users_url(represented)
    end
  end
end
