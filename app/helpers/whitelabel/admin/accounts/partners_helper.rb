
module Whitelabel::Admin::Accounts::PartnersHelper
  def legal_terms_toggling_link(account)
    if account.signs_legal_terms?
      text = 'Must click through legal agreements'
    else
      text = 'Immunity from legal agreements'
      klass = 'active'
    end
    link_to_if(current_user.has_permission?(:legal_terms), text, toggle_signs_legal_terms_partner_path(@account),
            :class => klass, :method => :put)
  end
end
