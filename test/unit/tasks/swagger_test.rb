require 'test_helper'

class Tasks::SwaggerTest < ActiveSupport::TestCase
  setup do
    accounts = FactoryBot.create_list(:simple_account, 2)
    accounts.each { |account| account.api_docs_services.create!(name: 'The Foo API', body: '{"basePath":"http://example.com", "apis":[]}') }
    accounts.first.delete
    assert_equal 2, ApiDocs::Service.count
  end

  test 'destroy_orphans' do
    DeleteObjectHierarchyWorker.expects(:perform_later).once.with { |swagger| swagger.account.blank? }
    execute_rake_task 'swagger.rake', 'swagger:destroy_orphans'
  end
end
