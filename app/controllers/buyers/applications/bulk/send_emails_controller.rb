# frozen_string_literal: true

class Buyers::Applications::Bulk::SendEmailsController < Buyers::Applications::Bulk::BaseController
  def create
    send_emails
    handle_errors
  end

  private

  def recipients
    @recipients ||= collection.map(&:user_account)
  end
end
