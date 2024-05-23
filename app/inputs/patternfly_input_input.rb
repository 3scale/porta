# frozen_string_literal: true

class PatternflyInputInput < Formtastic::Inputs::StringInput
  delegate :tag, to: :template

  def to_html
    tag.div(class: 'pf-c-form__group') do
      label + control
    end
  end

  private

  def input_html_options
    super.merge(class: 'pf-c-form-control',
                'aria-invalid': errors.any?)
  end

  def label
    tag.div(class: 'pf-c-form__group-label') do
      tag.label(class: 'pf-c-form__label', for: input_html_options[:id]) do
        tag.span(label_text, class: 'pf-c-form__label-text')
      end
    end
  end

  def control
    tag.div(class: 'pf-c-form__group-control') do
      input_group + helper_text
    end
  end

  def input_group
    tag.div(class: "pf-c-input-group") do
      input + action
    end
  end

  def input
    builder.text_field(method, input_html_options)
  end

  def action
    action_html_options = options.delete(:action)
    return nil if action_html_options.nil?

    action_title = action_html_options.delete(:title)
    action_html_options.reverse_merge!(class: 'pf-c-button pf-m-primary')
    tag.button(action_title, action_html_options)
  end

  def helper_text
    unless errors.empty? # rubocop:disable Style/IfUnlessModifier
      return template.render partial: 'shared/pf_error_helper_text', locals: { error: errors.first }
    end

    if hint? # rubocop:disable Style/GuardClause, Style/IfUnlessModifier
      tag.p(hint_text, class: 'pf-c-form__helper-text')
    end
  end
end
