# frozen_string_literal: true

require 'test_helper'

class CMS::SystemNameTest < ActiveSupport::TestCase

  class Template < ApplicationRecord
    self.table_name = 'cms_templates'

    include CMS::SystemName
  end

  class Validation < ActiveSupport::TestCase

    test "invalid format doesn't pass validation" do
      template = CMS::SystemNameTest::Template.new

      template.system_name = 'sys.name'

      assert_not template.valid?
      assert_equal 'System name invalid', template.errors.full_messages.first
    end

    test "repeated system_name doesn't pass validation" do
      provider = FactoryBot.create(:simple_provider)
      template = CMS::SystemNameTest::Template.new
      template.title = 'New template'
      template.provider_id = provider.id
      template.save

      template2 = CMS::SystemNameTest::Template.new
      template2.provider_id = provider.id
      template2.system_name = 'new-template'
      template2.save

      assert_not template2.valid?
      assert_equal 'System name has already been taken', template2.errors.full_messages.first
    end

    test "invalid length doesn't pass validation" do
      template = CMS::SystemNameTest::Template.new

      template.system_name = Array.new(25){'new-template'}.join

      assert_not template.valid?
      assert_equal 'System name is too long (maximum is 255 characters)', template.errors.full_messages.first
    end

    test "empty system_name doesn't pass validation" do
      template = CMS::SystemNameTest::Template.new

      assert_not template.valid?
      assert_equal "System name can't be blank", template.errors.full_messages.first
    end

    test "valid record passes validation" do
      provider = FactoryBot.create(:simple_provider)
      template = CMS::SystemNameTest::Template.new
      template.title = 'New template'
      template.system_name = 'sys_name'
      template.provider_id = provider.id
      template.save

      assert template.valid?
    end
  end

  class Create < ActiveSupport::TestCase
    def setup
      @provider = FactoryBot.create(:simple_provider)
    end

    test 'sets a valid system name if empty' do
      template = CMS::SystemNameTest::Template.new
      template.title = 'New template'
      template.provider_id = @provider.id

      template.save

      assert template.persisted?
      assert_equal 'new-template', template.reload.system_name
    end

    test "doesn't set system_name when it exists" do
      system_name = 'template1'
      template = CMS::SystemNameTest::Template.new
      template.title = 'New template'
      template.system_name = system_name
      template.provider_id = @provider.id

      template.save

      assert template.persisted?
      assert_equal system_name, template.reload.system_name
    end
  end

  class Update < ActiveSupport::TestCase
    def setup
      @provider = FactoryBot.create(:simple_provider)
      @template = CMS::SystemNameTest::Template.new
      @template.title = 'New template'
      @template.provider_id = @provider.id
      @template.save
    end

    test 'sets a valid system name if empty' do
      @template.update_column(:system_name, '')

      @template.title = 'Updated template'
      @template.save

      assert_equal 'updated-template', @template.reload.system_name
    end

    test "doesn't set system_name when it exists" do
      @template.title = 'Updated template'
      @template.save

      assert_equal 'new-template', @template.reload.system_name
    end

    test "sets system_name when provided" do
      system_name = 'template2'
      @template.title = 'Updated template'
      @template.system_name = system_name
      @template.save

      assert_equal system_name, @template.reload.system_name
    end
  end
end
