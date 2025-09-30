# frozen_string_literal: true

# TODO: when input is required, add input_html: required prop instead of doing it manually in every form.

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
    return ''.html_safe unless render_label?

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
      prefix + input + action
    end
  end

  def prefix
    return ''.html_safe unless (text = options.delete(:prefix))

    tag.span text, class: 'pf-c-input-group__text'
  end

  def input
    builder.text_field(method, input_html_options)
  end

  def action
    action_html_options = options.delete(:action)
    return ''.html_safe if action_html_options.nil?

    if action_html_options.is_a?(Symbol)
      case action_html_options
      when :remove
        tag.button(class: 'pf-c-button pf-m-plain', type: 'button', aria: { label: 'Remove' }) do
          tag.i(class: 'fas fa-minus-circle', aria: { hidden: 'true' })
        end
      else
        raise ArgumentError, "'#{action_html_options}' is not a valid action. Did you mean 'remove'?"
      end
    else
      action_title = action_html_options.delete(:title)
      action_html_options.reverse_merge!(class: 'pf-c-button pf-m-primary')
      tag.button(action_title, **action_html_options)
    end
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
