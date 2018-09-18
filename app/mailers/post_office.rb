class PostOffice < ActionMailer::Base

  helper ThreeScale::MoneyHelper

  def message_notification(message, recipient)
    custom = message.headers.symbolize_keys

    bcc = emails_for_message(message, recipient) + [custom.delete(:bcc)].flatten.compact
    cc = custom.delete(:cc)

    from = custom.delete(:from) || from_address(recipient.receiver)
    reply_to = custom.delete(:reply_to)

    headers({
      ::Message::APPLY_ENGAGEMENT_FOOTER => message.sender.should_apply_email_engagement_footer?,
      'Return-Path'                      => from,
      'Message-Uri'                     => message.to_sgid,
      'X-SMTPAPI'                        => '{"category": "Message Notification"}'
    }.merge(custom.stringify_keys))

    if message.origin == "web"
      subject = "[msg] #{message.subject}"

      msg_url = if recipient.receiver.buyer?
        developer_portal.admin_messages_inbox_url(recipient, host: recipient.receiver.provider_account.domain)
                else # provider or master
        provider_admin_messages_inbox_url(recipient, host: recipient.receiver.self_domain)
                end

      @sender = message.sender.org_name
      @msg = message.body
      @url = msg_url

      mail(:subject => subject,
           :bcc => bcc, :cc => cc, :from => from, :reply_to => reply_to)
    else
      mail(:subject => message.subject, :body => message.body,
           :bcc => bcc, :cc => cc, :from => from, :reply_to => reply_to)
    end
  rescue ArgumentError => e
    # More details for errors like: https://3scale.airbrake.io/projects/14982/groups/69448607
    new_message = "Message(#{message.id}),Recipient(#{recipient.id}): #{e.message}"
    raise ArgumentError.new(new_message)
  end

  def report(report, period)
    account = report.account

    headers(
      'Return-Path' => from_address(account),
      'X-SMTPAPI' => '{"category": "Report"}'
    )

    attachments["report-#{service_name(report)}.pdf"] = File.read(report.report.path)

    mail(
      :subject => "3scale: #{service_name(report)} - #{period}",
      :body => "Service: #{service_name(report)}\n\nPlease find attached your API Usage Report from 3scale.\n",
      :bcc => account.admins.map(&:email),
      :from => from_address(account)
    )
  end

  private

  def service_name(report)
    report.service.name
  end

  def emails_for_message(message, recipient)
    sender = message.sender
    receiver = recipient.receiver
    if (sender.master? || (sender.provider? && receiver.buyer?)) && sender.email_all_users
      receiver.users.map(&:email)
    else
      receiver.admins.map(&:email)
    end
  end

  def from_address(account)
    account.provider_account.try!(:from_email) || Rails.configuration.three_scale.noreply_email
  end
end
