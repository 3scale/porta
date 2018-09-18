module ProfilesHelper
  def custom_company_type?(profile)
    !profile.company_type.blank? and
      (profile.company_type == Profile::CustomCompanyType or
       !Profile::CompanyTypes.include?(profile.company_type))
  end
end
