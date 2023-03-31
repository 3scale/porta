# frozen_string_literal: true

require 'test_helper'
require Rails.root.join('db/migrate/20230308155529_backfill_titles_cms_sections')

class BackfillTitlesCMSSectionsTest < ActiveSupport::TestCase
  def setup
    @provider = FactoryBot.create(:provider_account)
    @migration = BackfillTitlesCMSSections.new
  end

  [nil, ""].each do |empty_val|
    test "section titles are fixed for #{empty_val.inspect}" do
      section = FactoryBot.build(:cms_section, partial_path: '/', parent: @provider.sections.root, title: empty_val, system_name: 'system-name')
      section.save!(validate: false)
      expected_title = section.system_name

      @migration.up

      assert_equal expected_title, section.reload.title
    end
  end

  test "sections with valid titles don't change" do
    title = 'Valid Title'
    sysname = 'valid-system-name'
    section = FactoryBot.create(:cms_section, partial_path: '/', provider: @provider,
                                parent: @provider.sections.root, title: title, system_name: sysname)

    @migration.up

    section.reload
    assert_equal title, section.title
    assert_equal sysname, section.system_name
  end
end
