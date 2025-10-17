# frozen_string_literal: true

class Sites::EmailsEditPresenter
  include System::UrlHelpers.system_url_helpers

  def initialize(user:)
    @user = user
  end

  attr_reader :user

  def props
    {
      buttonLabel: I18n.t('sites.emails.edit.add_exception'),
      removeConfirmation: I18n.t('sites.emails.remove_confirmation'),
      exceptions: exceptions.decorate.as_json(only: %i[id name system_name updated_at support_email], js: true),
      products: products_without_support_email.paginate(page: 1, per_page: 20).decorate.as_json(only: %i[id name system_name updated_at], js: true),
      productsCount: total_products_without_support_email,
      productsPath: url_for(controller: 'api/services', only_path: true),
    }
  end

  private

  def products
    @products ||= user.accessible_services
                      .order(name: :asc)
  end

  def products_without_support_email
    @products_without_support_email ||= products.where(support_email: nil)
  end

  def total_products_without_support_email
    @total_products_without_support_email ||= products_without_support_email.size
  end

  def exceptions
    @exceptions ||= products.where.not(support_email: nil)
  end
end
