module Provider::Admin::Onboarding::InfoHelper

  def hypothetical_api_base_url
    "https://api.#{parameterized_org_name_of_the_current_account}.com"
  end
end
