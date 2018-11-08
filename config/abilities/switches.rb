# frozen_string_literal: true

Ability.define do |user|
  if user && (account = user.account)

    provider = account.provider_account
    settings = if account.buyer?
                 provider.settings
               else
                 account.settings
               end

    # :see means buyer can use it (see buyer_any.rb)
    # :admin means provider can see the upgrade notices (see provider_admin.rb)
    # :manage means provider can show and hide it

    # end_users account_plans service_plans finance require_cc_on_signup
    # multiple_services multiple_applications multiple_users skip_email_engagement_footer
    # groups branding web_hooks iam_tools
    settings.switches.each do |name, switch|
      if can?(:admin, name) && switch.allowed?
        if account.master_on_premises? && [:account_plans, :service_plans].include?(name)
          cannot %i[see admin manage], name
        else
          can :manage, name
        end
      end
    end
  end
end
