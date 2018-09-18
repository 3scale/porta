module TestHelpers
  module SectionsPermissions

    #TODO: use this helper in cucumber section_steps

    #OPTIMIZE: do not create always, instead check for existance first
    def grant_buyer_access_to_section(buyer, section)
      prov = buyer.provider_account
      g = CMS::Group.create(:name => 'foo', :provider => prov)
      g.group_sections.create(:section => section)
      buyer.permissions.create(:group => g)
      buyer.save
    end

  end
end
