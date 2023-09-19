# frozen_string_literal: true

class PatternflyInputInput < Formtastic::Inputs::StringInput
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
    hint = content_tag(:p, hint_text, class: 'pf-c-form__helper-text') if hint?
    content_tag :div, class: 'pf-c-form__group-control' do
      input + helper_text + hint
    end
  end

  def input
    builder.text_field(method, input_html_options.merge(class: 'pf-c-form-control',
                                                        'aria-invalid': errors.any?))
  end

  def helper_text
    return if errors.empty?

    template.render partial: 'shared/pf_error_helper_text', locals: { error: errors.first }
  end
end
