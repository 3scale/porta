# frozen_string_literal: true

# CMS
class SectionInput < Formtastic::Inputs::SelectInput
  def input_html_options
    super.reverse_merge(collection: collection)
  end

  def select_html
    super unless options.key?(:paths)

    paths = Hash[sections.partial_paths]
    super << template.javascript_tag("$.partial_paths(#{paths.to_json});")
  end

  def include_blank
    false
  end

  private

  def sections
    @sections ||= template.current_account.sections
  end

  def collection
    template.cms_section_select(sections.root)
  end
end
