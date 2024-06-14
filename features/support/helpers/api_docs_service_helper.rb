# frozen_string_literal: true

module ApiDocsServiceHelper

  def spec_body_builder(swagger_version)
    file_fixture("swagger/echo-api-#{swagger_version}.json").read
  end

  def fill_in_api_docs_service_body(value)
    page.execute_script "document.querySelector('.CodeMirror').CodeMirror.setValue(#{value.dump})"

    find('.pf-c-page__main-section').click # HACK: need to click outside to lose focus
  end

  def numbered_swagger_version(version)
    {
      'Swagger 1.2' => '1.2',
      'Swagger 2' => '2.0',
      'OAS 3.0' => '3.0'
    }[version]
  end

end

World(ApiDocsServiceHelper)
