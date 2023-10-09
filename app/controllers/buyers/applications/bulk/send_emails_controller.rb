# frozen_string_literal: true

class Buyers::Applications::Bulk::SendEmailsController < Buyers::Applications::Bulk::BaseController
  def create
    send_emails
    handle_errors
    super
  end

  private

  def recipients
    @recipients ||= collection.map(&:user_account)
  end

  def errors_template
    'buyers/accounts/bulk/shared/errors.html'
  end
end
