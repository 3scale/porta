# frozen_string_literal: true

module ApplicationsHelper
  def raw_buyers
    # This has to be the samne collection as in Buyers::AccountsController#index
    provider.buyer_accounts
            .not_master
            .order(created_at: :desc, id: :asc)
  end

  def filtered_buyers(search)
    raw_buyers.scope_search(search)
  end

  def paginated_buyers
    raw_buyers.paginate(pagination_params)
  end

  def raw_products
    # This has to be the samne collection as in Api::ServicesController#index
    provider.accessible_services
            .order(updated_at: :desc)
  end

  def filtered_products(search)
    raw_products.scope_search(search)
  end

  def paginated_products
    raw_products.paginate(pagination_params)
  end

  # TODO: need to refactor this method, there is no default return value
  def create_application_link_href(account)
    if account.bought_cinstances.size.zero?
      new_admin_buyers_account_application_path(account)
    elsif can?(:admin, :multiple_applications)
      if can?(:see, :multiple_applications)
        new_admin_buyers_account_application_path(account)
      else
        admin_upgrade_notice_path(:multiple_applications)
      end
    end
  end

  def last_traffic(cinstance)
    return unless cinstance.first_daily_traffic_at?

    date = cinstance.first_daily_traffic_at
    title = "#{time_ago_in_words(date)} ago"
    time_tag(date, date.strftime("%B %e, %Y"), title: title)
  end

  def time_tag_with_title(date_or_time, *args)
    options =  args.extract_options!
    title = args.first || I18n.l(date_or_time, :format => :long)
    args << options.reverse_merge!(:title => title)
    time_tag date_or_time.to_date, *args
  end

  def remaining_trial_days(cinstance)
    expiration_date = cinstance.trial_period_expires_at
    expiration_tag = time_tag(expiration_date,
                              distance_of_time_in_words(Time.zone.now, expiration_date),
                              title: l(expiration_date))
    "&ndash; trial expires in #{expiration_tag}".html_safe # rubocop:disable Rails/OutputSafety
  end

  def new_application_form_base_data(provider, cinstance)
    # TODO: Reduce data by not including service_plans when service_plans_management_visible? is false
    data = {
      'create-application-plan-path': new_admin_service_application_plan_path(':id'),
      'create-service-plan-path': new_admin_service_service_plan_path(':id'),
      'service-subscriptions-path': admin_buyers_account_service_contracts_path(':id'),
      'service-plans-allowed': service_plans_management_visible?.to_json,
      'defined-fields': application_defined_fields_data(provider).to_json
    }
    data[:errors] = cinstance.errors.to_json if cinstance
    data
  end

  def most_recently_created_buyers
    BuyerDecorator.decorate_collection(raw_buyers.limit(20))
                  .map(&:new_application_data)
  end

  def most_recently_updated_products
    ServiceDecorator.decorate_collection(raw_products.limit(20))
                    .map(&:new_application_data)
  end

  def application_defined_fields_data(provider)
    provider.fields_definitions
            .where(target: 'Cinstance')
            .map do |field|
              FieldsDefinitionDecorator.new(field).new_application_data(provider)
            end
  end
end
