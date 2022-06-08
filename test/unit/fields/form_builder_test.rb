# frozen_string_literal: true

require 'test_helper'

class Fields::FormBuilderTest < ActiveSupport::TestCase
  test 'builtin field with options' do
    builder = form_builder(:user)

    field = FieldsDefinition.new
    field.name = :signup_origin

    user = builder.object

    user.stubs(:field).with(:signup_origin).returns(field)
    user.stubs(:extra_field?).with('signup_origin').returns(false)
    user.stubs(:internal_field?).with('signup_origin').returns(false)

    input_html_options = { input_html: { class: 'my-class' }}
    builder.expects(:input).with(:signup_origin, { label: "Signup origin", required: false, hint: nil }.merge(input_html_options)).returns('')

    builder.field(:signup_origin, input_html_options)
  end

  def form_builder(object_name)
    object = mock(object_name.to_s)
    template = mock('template')
    Fields::FormBuilder.new(object_name, object, template, {})
  end
end
