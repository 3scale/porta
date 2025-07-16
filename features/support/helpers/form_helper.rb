# frozen_string_literal: true

module FormHelper
  def submit_form_with(table)
    fill_form_with(table)
    find('.pf-c-form__actions button[type="submit"], .formtastic [type="submit"]').click
  end

  def fill_form_with(table)
    # wait for the form to be rendered
    assert has_element? 'form'
    table.rows_hash.each do |name, value|
      if has_select?(name, wait: 0)
        select(value, from: name)
      elsif has_field?(name, type: 'checkbox', wait: 0)
        if value.casecmp?('yes')
          check(name)
        elsif value.casecmp?('no')
          uncheck(name)
        else
          raise ArgumentError, 'Use Yes/No for checkbox fields'
        end
      else
        fill_in(name, with: value)
      end
    end
  end

  # TODO: extend Node::Actions#select instead of using a custom method.
  def pf4_select(value, from:)
    within %(.pf-c-select[data-ouia-component-id="#{from}"]) do
      find('button.pf-c-select__toggle, button.pf-c-select__toggle-button').click if has_no_css?('.pf-c-select__menu', wait: 0)
      find('.pf-c-select__menu button', text: value).click
    end
  end

  def pf4_select_first(from:)
    select = find_pf_select(from)
    within select do
      find('.pf-c-select__toggle').click unless select['class'].include?('pf-m-expanded')
      find('.pf-c-select__menu .pf-c-select__menu-item:not(.pf-m-disabled)').click
    end
  end

  # def has_pf_select?(label_or_placeholder)
  #   has_css?(".pf-c-select[data-ouia-component-id=\"#{label_or_placeholder}\"]", wait: 0)
  # end

  def find_pf_select(label_or_placeholder)
    find %(.pf-c-select[data-ouia-component-id="#{label_or_placeholder}"])
  end
end

World(FormHelper)
