require 'test_helper'

class CMS::UpgradeContentWorkerTest < ActiveSupport::TestCase
  def setup
    @worker = CMS::UpgradeContentWorker.new
  end

  def test_upgrade_include
    provider = FactoryGirl.create(:simple_provider)
    section = FactoryGirl.create(:root_cms_section, provider: provider)
    page = FactoryGirl.create(:cms_page, provider: provider, section: section)
    page.published = "{% include 'login/cas' %}"
    page.draft = "{%  include 'signup/cas'  %}"
    page.save!

    @worker.upgrade_include(page)
    page.reload

    assert_equal "{% include 'login/cas' with cas %}", page.published
    assert_equal "{% include 'signup/cas' with cas %}", page.draft
  end
end
