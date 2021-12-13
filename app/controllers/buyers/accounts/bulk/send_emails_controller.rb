# frozen_string_literal: true

class Buyers::Accounts::Bulk::SendEmailsController < Buyers::Accounts::Bulk::BaseController

  def new; end

  def create
    @errors = []

    @accounts.each do |recipient|
      message = current_account.messages.build send_emails_params
      message.to = recipient
      @errors << message unless message.save && message.deliver!
    end

    handle_errors
  end

  private

  def send_emails_params
    params.fetch(:send_emails).permit!
  end
end
