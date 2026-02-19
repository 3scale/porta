# frozen_string_literal: true

require 'test_helper'

class YamlSerializationLegacyFormatTest < ActiveSupport::TestCase
  # This test ensures that legacy YAML data serialized with !map:HashWithIndifferentAccess
  # can be deserialized properly. This format was used in older versions of Rails.
  #
  # CONTEXT: The primary use case is the `extra_fields` column on the `cinstances` table.
  # Extra fields are custom fields defined by FieldsDefinition and stored as a Hash
  # in the extra_fields column (serialized as YAML). The keys are the field names
  # and values are user-provided data.
  #
  # The fix is in config/application.rb where 'HashWithIndifferentAccess' (as a string)
  # is added to yaml_column_permitted_classes.
  #
  # Without this fix, loading old YAML would raise:
  #   Psych::DisallowedClass: Tried to load unspecified class: HashWithIndifferentAccess

  test 'can deserialize legacy HashWithIndifferentAccess YAML format in Cinstance extra_fields' do
    # Setup: Create a provider account that will own the fields definitions
    provider = FactoryBot.create(:provider_account)

    # Setup: Create custom field definition for Cinstance (applications)
    FactoryBot.create(:fields_definition, account: provider,
      target: 'Cinstance', name: 'custom_field', label: 'Custom Field'
    )

    # Setup: Create a buyer account and an application (Cinstance)
    plan = FactoryBot.create(:application_plan, issuer: provider.first_service!)
    application = FactoryBot.create(:cinstance, plan: plan)

    # Simulate legacy data: Update the extra_fields column directly with old YAML format
    # This is what exists in production databases from older Rails versions
    legacy_yaml = <<~YAML.strip
      --- !map:HashWithIndifferentAccess
      custom_field: custom_value
    YAML

    ActiveRecord::Base.connection.execute(
      "UPDATE cinstances SET extra_fields = #{ActiveRecord::Base.connection.quote(legacy_yaml)} WHERE id = #{application.id}"
    )

    # Test: Reload the application and verify the legacy YAML can be deserialized
    application.reload

    assert_instance_of ActiveSupport::HashWithIndifferentAccess, application.extra_fields

    # Verify the field values are correctly deserialized
    assert_equal 'custom_value', application.extra_fields['custom_field']
    assert_equal 'custom_value', application.extra_fields[:custom_field]

    # Re-save to trigger modern serialization
    application.save!

    # Check the raw database value - should not contain old tag
    raw_yaml = ActiveRecord::Base.connection.select_value(
      "SELECT extra_fields FROM cinstances WHERE id = #{application.id}"
    )

    assert_not_includes raw_yaml, '!map:HashWithIndifferentAccess',
                        'Re-serialized extra_fields should use modern format'

    # But data should still be accessible
    application.reload
    assert_equal 'custom_value', application.extra_fields['custom_field']
    assert_equal 'custom_value', application.extra_fields[:custom_field]
  end

  test 'legacy YAML format is included in permitted classes configuration' do
    permitted_classes = Rails.application.config.active_record.yaml_column_permitted_classes

    # Must include the string 'HashWithIndifferentAccess' for Psych to resolve the YAML tag
    # This is critical for deserializing old extra_fields data in cinstances and other models
    assert_includes permitted_classes, 'HashWithIndifferentAccess',
                    "Config must include 'HashWithIndifferentAccess' string to support legacy YAML format in extra_fields"

    # Also verify the class itself is included (for modern YAML)
    assert_includes permitted_classes, ActiveSupport::HashWithIndifferentAccess,
                    "Config should include ActiveSupport::HashWithIndifferentAccess class"
  end
end
