# frozen_string_literal: true

module ApiDocsServiceHelper

  def spec_body_builder(swagger_version)
    spec_name = swagger_version[:invalid] ? 'invalid' : 'echo-api'
    file_fixture("swagger/#{spec_name}-#{swagger_version[:version]}.json").read
  end

  def fill_in_api_docs_service_body(value)
    page.execute_script "document.querySelector('.CodeMirror').CodeMirror.setValue(#{value.dump})"

    find('.pf-c-page__main-section').click # HACK: need to click outside to lose focus
  end

  def transform_swagger_version(spec_version)
    match =  /(invalid)?\s?(Swagger 1.2|Swagger 2|OAS 3.0|OAS 3.1)/.match(spec_version)
    { version: numbered_swagger_version(match[2]), invalid: match[1].present? }
  end

  def numbered_swagger_version(version)
    {
      'Swagger 1.2' => '1.2',
      'Swagger 2' => '2.0',
      'OAS 3.0' => '3.0',
      'OAS 3.1' => '3.1'
    }[version]
  end

end

World(ApiDocsServiceHelper)
