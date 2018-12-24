require 'test_helper'

class CMS::BuiltinTest < ActiveSupport::TestCase
  def setup
    @provider = FactoryBot.create(:provider_account)
  end

  test 'destroy! can only be used' do
    section = @provider.sections.first!

    builtin = section.builtins.create!(system_name: 'builtin', provider: @provider)

    # CMS::Builtin#destroy is private
    assert_raise(NoMethodError) { builtin.destroy }

    # This works because #destroy! is defined as:
    #
    #   def destroy!
    #     destroy || raise(RecordNotDestroyed.new("Failed to destroy the record", self))
    #   end
    #
    #  So calling a private method here is OK
    Rails.logger.expects(:warn)
    builtin.destroy!
  end
end
