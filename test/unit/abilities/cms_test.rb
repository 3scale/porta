require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Abilities::CmsTest < ActiveSupport::TestCase
  #TODO: update/finish this? they can be a bit undry/unneeded with features/authorization/*.feature
  context 'enterprise mode provider admin' do
    setup do
      @provider = FactoryBot.create(:provider_account)
    end

    should "manage the portal" do
      ability = Ability.new(@provider.admins.first)
      assert ability.can?(:manage, :portal)
    end
  end
end
