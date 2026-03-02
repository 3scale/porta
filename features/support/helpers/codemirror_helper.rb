# frozen_string_literal: true

# TODO: compbine this with features/support/helpers/api_docs_service_helper.rb
module CodeMirrorHelper
  def fill_in_codemirror(id, value)
    page.execute_script "document.querySelector('##{id} .CodeMirror').CodeMirror.setValue(#{value.dump})"

    find('.pf-c-page').click # HACK: need to click outside to lose focus
  end
end
