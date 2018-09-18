module Buyers::AccountsHelper

  def public_domain(account)
    access_code = "/access_code?access_code=#{account.site_access_code}" if account.site_access_code
    "http://#{account.domain}#{access_code}".html_safe
  end

  def account_title account
    [ h(account.org_name), h(account.admin_user.try!(:display_name)) ].compact.join(" &mdash; ").html_safe
  end

  def link_to_buyer_or_deleted( buyer, path_method = :admin_buyers_account_path)
    if buyer
      if can? :manage, :partners
        path = path_method.is_a?(Symbol) ? send( path_method, buyer) : path_method
        link_to buyer.org_name, path, :title => account_title(buyer)
      else
        buyer.org_name
      end
    else
      '<span class="deleted">(deleted)</span>'.html_safe
    end
  end

end
