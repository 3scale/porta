require 'test_helper'

class CMS::Builtin::SectionTest < ActiveSupport::TestCase
  def setup
    @provider = FactoryBot.create(:provider_account)
  end

  test 'destroy! can only be used' do
    section = @provider.builtin_sections.first!
    section.stubs(root?: false)

    # CMS::Builtin::Section#destroy is private
    assert_raise(NoMethodError) { section.destroy }

    Rails.logger.expects(:warn)
    section.destroy!
  end
end
