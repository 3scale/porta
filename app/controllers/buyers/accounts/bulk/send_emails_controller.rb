# frozen_string_literal: true

class Buyers::Accounts::Bulk::SendEmailsController < Buyers::Accounts::Bulk::BaseController
  def create
    send_emails
    handle_errors
    super
  end

  alias recipients accounts
end
