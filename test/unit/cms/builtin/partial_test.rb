require 'test_helper'

class CMS::Builtin::PartialTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryBot.create(:simple_provider)
  end

  test 'cannot be deleted' do
    partial = FactoryBot.build(:cms_builtin_partial, provider: @provider)

    assert_equal false, partial.respond_to?(:destroy)
    assert_raises(NoMethodError) { partial.destroy }
  end

  test 'should use reserved system_name' do
    partial = @provider.builtin_partials.create(system_name: 'applications/form')
    assert_empty partial.errors[:system_name]
  end

  test 'cannot use arbitrary system_names' do
    partial = @provider.builtin_partials.create(system_name: 'some_other_name')
    assert_not_empty partial.errors[:system_name]
  end

  test 'should allow update also if the system_name no exists on the whitelist' do
    partial = @provider.builtin_partials.create(system_name: 'applications/form')
    CMS::Builtin::Partial.stubs system_name_whitelist: []
    assert partial.save
  end

  test 'should not allow change the system name' do
    partial = @provider.builtin_partials.create(system_name: CMS::Builtin::Partial.system_name_whitelist.first)

    partial.system_name = partial.system_name
    assert partial.save

    partial.system_name = CMS::Builtin::Partial.system_name_whitelist.last
    refute partial.save
  end

  test 'can be reset' do
    partial = FactoryBot.build(:cms_builtin_partial, provider: @provider,
                          # has to be a known system_name
                          system_name: 'applications/form')
    partial.draft = 'BEFORE'
    partial.save!

    assert_equal partial.draft, 'BEFORE'
    partial.reset!
    assert_not_equal partial.draft, 'BEFORE'
  end

  test 'always has liquid enabled' do
    partial = FactoryBot.build(:cms_builtin_partial, provider: @provider, liquid_enabled: false)
    assert partial.liquid_enabled?, 'liquid processing disabled for builtin page'
  end

  test 'content_type is text/html' do
    page = FactoryBot.build(:cms_builtin_partial, provider: @provider)
    assert_equal 'text/html', page.content_type
  end

end
