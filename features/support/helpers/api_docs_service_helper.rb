# frozen_string_literal: true

module ApiDocsServiceHelper

  def spec_body_builder(swagger_version)
    file_fixture("swagger/echo-api-#{swagger_version}.json").read
  end

  def fill_in_api_docs_service_body(value)
    # HACK: fill_in('API JSON Spec', visible: :hidden, with: FactoryBot.build(:api_docs_service).body) doesn't work because capybara rises ElementNotInteractableError
    page.execute_script("$('textarea#api_docs_service_body').css('display','')")
    find('textarea#api_docs_service_body').set(value)
    find('.pf-c-page__main-section').click # HACK: need to click outside to lose focus
  end

end

World(ApiDocsServiceHelper)
