# frozen_string_literal: true

class Buyers::Accounts::Bulk::SendEmailsController < Buyers::Accounts::Bulk::BaseController
  private

  def recipients
    @recipients ||= @accounts
  end
end
