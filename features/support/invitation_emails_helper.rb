module InvitationEmailsHelper

  def invitation_message_should_be_valid(message, inviting_account, domain = inviting_account.provider_account.domain)
    assert_not_nil message
    assert_equal "Invitation to join #{inviting_account.org_name}", message.subject

    regexp = if inviting_account.provider?
               %r{https:\/\/#{Regexp.quote(inviting_account.admin_domain)}/p/signup/[a-f0-9]+}
             else
               %r{https:\/\/#{Regexp.quote(domain)}/signup/[a-f0-9]+}
             end

    assert_match(regexp, message.body.to_s)

    assert_match(
      "You have been invited to join #{inviting_account.org_name}", message.body.to_s
    )
  end

end

World(InvitationEmailsHelper)
