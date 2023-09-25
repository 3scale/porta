# frozen_string_literal: true

class PatternflyTextareaInput < Formtastic::Inputs::TextInput
  delegate :content_tag, to: :template

  def to_html
    content_tag :div, class: 'pf-c-form__group' do
      label + control
    end
  end

  private

  def label
    content_tag :div, class: 'pf-c-form__group-label' do
      content_tag :label, class: 'pf-c-form__label', for: input_html_options[:id] do
        content_tag :span, label_text, class: 'pf-c-form__label-text'
      end
    end
  end

  def control
    content_tag :div, class: 'pf-c-form__group-control' do
      builder.text_area(method, input_html_options.merge(class: 'pf-c-form-control pf-m-resize-vertical'))
    end
  end
end
