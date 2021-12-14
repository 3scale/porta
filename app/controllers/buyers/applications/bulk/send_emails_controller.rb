# frozen_string_literal: true

class Buyers::Applications::Bulk::SendEmailsController < Buyers::Applications::Bulk::BaseController
  private

  def recipients
    @recipients ||= @applications.map(&:user_account)
  end
end
