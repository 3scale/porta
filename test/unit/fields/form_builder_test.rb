require 'test_helper'

class Fields::FormBuilderTest < ActiveSupport::TestCase
  def test_field_with_options
    builder = form_builder(:user)

    field = FieldsDefinition.new
    field.name = :signup_origin

    user = builder.object

    user.stubs(:field).with(:signup_origin).returns(field)
    user.stubs(:extra_field?).with('signup_origin').returns(false)
    user.stubs(:internal_field?).with('signup_origin').returns(false)

    builder.template.expects(:text_field).with(:user, :signup_origin, has_entry(class: 'my-class')).returns('')

    builder.field(:signup_origin, { input_html: { class: 'my-class' }})
  end


  def form_builder(object_name, template = {params: nil, content_tag: '', label: ''}, options = {}, proc = Proc.new{})
    object = mock(object_name.to_s)
    template = mock('template', template)
    Fields::FormBuilder.new(object_name, object, template, {})
  end
end
