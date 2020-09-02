# encoding: utf-8
require 'test_helper'

class ApiDocs::ServiceTest < ActiveSupport::TestCase

  setup do
    @account = FactoryBot.create(:simple_provider)
    @notify = NotificationCenter.disabled.dup
    NotificationCenter.disabled << ApiDocs::Service
  end

  attr_reader :account
  def teardown
    NotificationCenter.disabled = @notify
  end

  test 'save and skip_swagger_validations' do
    service = account.api_docs_services.new(name: 'this is a random name', body: '{}', skip_swagger_validations: '0')
    service.specification.expects(:validate!).once
    service.save

    service = account.api_docs_services.new(name: 'and another random name', body: '{}', skip_swagger_validations: '1')
    service.specification.expects(:validate!).never
    service.save
  end

  test 'base_path notifications' do
    service = account.api_docs_services.new name: 'The API'

    service.body = <<-EOJSON
      {
        "apis": [null],
        "basePath": "http://my-base-path.com"
      }
    EOJSON
    service.expects(:new_base_path?).returns(true)
    service.save

    service.body = <<-EOJSON
      {
        "apis": [{}],
        "basePath": "http://my-base-path.com"
      }
    EOJSON
    service.expects(:new_base_path?).returns(false)
    service.save

    service.body = <<-EOJSON
      {
        "apis": [{}],
        "basePath": "http://another-base-path.com"
      }
    EOJSON
    service.expects(:new_base_path?).returns(true)
    service.save
  end

  test 'body and name are required' do
    service = account.api_docs_services.new
    refute service.valid?

    refute service.errors[:name].empty?
    refute service.errors[:body].empty?
  end

  test 'invalid json' do
    service = account.api_docs_services.new name: 'Crystal Clear API', body: 'YOLO'

    refute service.valid?
    assert service.errors[:body].presence, 'expected errors on body'

    assert_equal 'Invalid JSON',  service.errors[:body].first

    service.body= "{}"

    refute service.valid?

    assert_equal 'JSON Spec is invalid', service.errors[:body].first
  end

  test 'validates json body, apis should not be NULL' do
    json = <<-EOJSON
      {
        "apis": "panda"
      }
    EOJSON

    service = account.api_docs_services.new name: 'my api', body: json

    refute service.valid?

    assert_equal 'JSON Spec is invalid', service.errors[:body].first

    service.body = <<-EOJSON
      {
        "apis": [null],
        "basePath": "http://www.example.com"
      }
    EOJSON

    assert service.valid?, service.errors.full_messages.join(", ")
    assert_equal "1.0", service.swagger_version

    service.body = <<-EOJSON
      {
        "apis": null
      }
    EOJSON
    refute service.valid?
  end

  test 'validates json body to not contain paramtype="query" and paramtype="body" for same method' do
    json = <<-EOJSON
      {
        "apis": [
          {
            "path": "/a-path",
            "responseClass": "A-Template",
            "operations": [
              {
                "httpMethod": "POST",
                "summary": "all the things",
                "description": "POST all the things",
                "parameters": [
                  {
                    "name": "page",
                    "paramType": "query",
                  },
                  {
                    "name": "file",
                    "paramType": "body"
                  }
                ]
              }
            ]
          }
        ]
      }
    EOJSON

    service = account.api_docs_services.new name: 'my api', body: json

    refute service.valid?
    refute service.errors[:body].empty?
  end

  test 'a valid json body' do
    json = <<-EOJSON
      {
        "basePath": "http://example.com",
        "apis": [
          {
            "path": "/another-path",
            "responseClass": "AnotherTemplate",
            "operations": [
              {
                "httpMethod": "GET",
                "summary": "all the things",
                "description": "GET all the things",
                "parameters": [
                  {
                    "name": "page",
                    "paramType": "query"
                  }
                ]
              },
              {
                "httpMethod": "POST",
                "summary": "all the things",
                "description": "POST all the things",
                "parameters": [
                  {
                    "name": "file",
                    "paramType": "body"
                  }
                ]
              }
            ]
          }
        ]
      }
    EOJSON

    service = account.api_docs_services.new name: 'my api', body: json

    assert service.valid?, service.errors.full_messages.join(", ")
    assert service.errors[:body].empty?
  end

  test 'base_path validation' do
    service = account.api_docs_services.new name: 'my api'

    ['', 'http://google', 'http://.com', 'http://ftp://ftp.google.com', 'http://ssh://google.com', 'http://example.net'].each do | valid_url |
      service.body = <<-EOJSON
        {
          "apis": [{}],
          "basePath": "#{valid_url}"
        }
      EOJSON
      assert service.valid?, service.errors.full_messages.join(", ")
      assert service.errors[:base_path].empty?
    end

    ['http:/www.google.com', '<>hi', 'www.google.com', 'google.com', 'ftp://ftp.google.com', 'ssh://google.com'].each do | invalid_url |
      service.body = <<-EOJSON
        {
          "apis": [{}],
          "basePath": "#{invalid_url}"
        }
      EOJSON
      refute service.valid?
      refute service.errors[:base_path].empty?
    end
  end

  test 'localhost validation' do
    service = account.api_docs_services.new name: 'my api', skip_swagger_validations: true

    ['', 'http://google', 'http://.com', 'http://localhost.example.com', 'http://ftp://ftp.google.com', 'http://ssh://google.com', 'http://example.net'].each do | valid_url |
      service.body = <<-EOJSON
        {
          "apis": [{}],
          "basePath": "#{valid_url}"
        }
      EOJSON
      assert service.valid?, service.errors.full_messages.join(", ")
      assert service.errors[:base_path].empty?
    end

    ['http://localhost/', 'http://LOCALHOST'].each do | invalid_url |
      service.body = <<-EOJSON
          {
            "apis": [{}],
            "basePath": "#{invalid_url}"
          }
      EOJSON
      refute service.valid?, "expected #{invalid_url} to be invalid"
      refute service.errors[:base_path].empty?
    end
  end

  test 'ip address validation' do
    service = account.api_docs_services.new name: 'my api'

    ['', 'http://google', 'http://smth', 'http://ftp://ftp.google.com', 'http://ssh://google.com', 'http://174.129.235.69', 'http://174.129.235.69:8080', 'http://54.234.21.19/v1/przyslist.json?district=lsm'].each do | url |
      service.body = <<-EOJSON
        {
          "apis": [{}],
          "basePath": "#{url}"
        }
      EOJSON
      assert service.valid?, service.errors.full_messages.join(", ")
      assert service.errors[:base_path].empty?
    end
  end

  test 'invalid base_path that has been saved should be modifiable' do
    body = <<-EOJSON
      {
        "apis": [null],
        "basePath": "http://my-base-path.com"
      }
    EOJSON

    service = account.api_docs_services.create(name: 'api', body: body, skip_swagger_validations: '0')

    # there's no way to save invalid base_path through ActiveRecord by now
    ActiveRecord::Base.connection.execute("UPDATE #{ApiDocs::Service.table_name} SET base_path='http://localhost:26447' WHERE id = #{service.id}")

    service.reload

    assert service.base_path, 'http://localhost:26447'

    service.body = <<-EOJSON
      {
        "apis": [null],
        "basePath": "http://my-base-path.com"
      }
    EOJSON

    service.save

    assert service.base_path, 'http://my-base-path.com'
  end

  # Eventually this is a valid swagger 2.0 spec
  test 'swagger 2.0' do
    json = <<-EOJSON
    {
      "swagger": "2.0",
      "info": {"title":"MegaAPI", "version":"0.1"},
      "paths": {}
    }
    EOJSON

    service = account.api_docs_services.new name: 'MyAPI', body: json

    assert_equal "2.0", service.swagger_version

    assert service.valid?, service.errors.full_messages.join(", ")
  end

  test 'validation of basePath without downcase xxxxxxxxxx1' do
    json = <<-EOJSON
    {
      "swagger": "2.0",
      "info": {"title":"MegaAPI", "version":"0.1"},
      "paths": {},
      "host": "petstore.swagger.io",
      "basePath": "//api"
    }
    EOJSON
    # json = {
    #     swagger: '2.0',
    #     info: {}
    # }.to_json

    service = account.api_docs_services.new name: 'MyAPI', body: json

    assert service.valid?, service.errors.full_messages.join(", ")

    assert_equal "2.0", service.swagger_version
  end

  test 'validation of basePath working only with downcase in line 20 in specification.rb ' do
    json = <<-EOJSON
    {
      "swagger": "2.0",
      "info": {"title":"MegaAPI", "version":"0.1"},
      "paths": {},
      "host": "petstore.swagger.io",
      "basePath": "api"
    }
    EOJSON

    service = account.api_docs_services.new name: 'MyAPI', body: json

    refute service.valid?, "expected api to be invalid"
    #refute service.errors[:base_path].empty?
  end


  # test 'validation of basePath without downcase xxxxxxxxxx2' do
  #   json = <<-EOJSON
  #   {
  #     "swagger": "2.0",
  #     "info": {"title":"MegaAPI", "version":"0.1"},
  #     "paths": {}
  #     "host": "petstore.swagger.io"
  #     "basePath": "//api"
  #   }
  #   EOJSON
  #
  #   service = ApiDocs::Service.new name: 'UberAPI', body: json
  #
  #   assert_equal "2.0", service.swagger_version
  #
  #   assert service.valid?, service.errors.full_messages.join(", ")
  # end

  test 'invalid swagger 2.0' do
    json = <<-EOJSON
    {
      "swagger": "2.0",
      "info": {"title":"MegaAPI", "version":"2.1"}
    }
    EOJSON

    service = account.api_docs_services.new name: 'MyAPI', body: json

    refute service.valid?
    assert_includes service.errors[:body], %q{The property '#/' did not contain a required property of 'paths' in schema http://swagger.io/v2/schema.json#}
  end

  test 'unsuported swaggerVersion' do
    json = <<-EOJSON

{
   "resourcePath" : "/api/v1/dataset",
   "apiVersion" : "0.1",
   "swaggerVersion" : "1.1",
   "apis" : [
      {
         "operations" : [
            {
               "parameters" : [
                  {
                     "required" : true,
                     "paramType" : "path",
                     "name" : "alias",
                     "type" : "string",
                     "allowMultiple" : false,
                     "description" : "Dataset ID"
                  },
                  {
                     "required" : true,
                     "paramType" : "body",
                     "name" : "ignored",
                     "type" : "string",
                     "allowMultiple" : false,
                     "description" : "Ignored body",
                     "defaultValue" : "{}"
                  }
               ],
               "authorizations" : {},
               "httpMethod" : "DELETE",
               "summary" : "Remove a dataset alias",
               "nickname" : "removeAlias",
               "type" : "void"
            }
         ],
         "path" : "/api/v1/dataset/dataset/alias/{alias}"
      }
   ],
   "basePath" : "https://connect-staging.simacan.com"
}
    EOJSON

    service = account.api_docs_services.new name: 'Le My-my API', body: json

    assert service.valid?, service.errors.full_messages.join(", ")

    assert_equal "1.0", service.swagger_version

    refute service.specification.swagger?
  end

  test 'valid swagger spec' do

    json = <<-EOJSON
{
   "resourcePath" : "/api/v1/dataset",
   "apiVersion" : "0.1",
   "swaggerVersion" : "1.2",
   "apis" : [
      {
         "operations" : [
            {
               "parameters" : [
                  {
                     "required" : true,
                     "paramType" : "path",
                     "name" : "alias",
                     "type" : "string",
                     "allowMultiple" : false,
                     "description" : "Dataset ID"
                  },
                  {
                     "required" : true,
                     "paramType" : "body",
                     "name" : "ignored",
                     "type" : "string",
                     "allowMultiple" : false,
                     "description" : "Ignored body",
                     "defaultValue" : "{}"
                  }
               ],
               "authorizations" : {},
               "method" : "DELETE",
               "summary" : "Remove a dataset alias",
               "nickname" : "removeAlias",
               "type" : "void"
            }
         ],
         "path" : "/api/v1/dataset/dataset/alias/{alias}"
      }
   ],
   "basePath" : "https://connect-staging.simacan.com"
}
    EOJSON

    service = account.api_docs_services.new name: 'my API', body: json

    assert service.valid?, service.errors.full_messages.join(", ")

    assert_equal "1.2", service.swagger_version

    assert service.specification.swagger?

  end

  test 'invalid json body' do
    service = account.api_docs_services.new name: 'my api', body: 'cucu'

    refute service.valid?
    refute service.errors[:body].empty?
  end

  #regression test
  test "operations without 'parameters' should not raise Exception" do
    # <#<NoMethodError: undefined method `map' for nil:NilClass>>.

    json = <<-EOJSON
    {
      "basePath": "http://nif.heroku.com",
      "apiVersion": "v1",
      "apis": [
        {
          "path": "/random",
          "operations": [
            {
              "httpMethod": "GET",
              "summary": "Returns a random valid nif"
            }
          ]
        }
      ]
    }

    EOJSON

    service = account.api_docs_services.new name: 'my api', body: json

    assert service.valid?

    assert_equal "1.0", service.swagger_version
  end

  test 'It validates the Service belongs to the Account if both are set' do
    service          = FactoryBot.create(:simple_service, account: account)
    another_account  = FactoryBot.create(:simple_provider)

    api_doc = service.api_docs_services.new(valid_attributes)
    api_doc.account = account
    assert api_doc.valid?

    api_doc = account.api_docs_services.new(valid_attributes)
    assert api_doc.valid?

    api_doc = service.api_docs_services.new(valid_attributes)
    api_doc.account = another_account
    refute api_doc.valid?
    assert_includes api_doc.errors[:service], 'not found'

    api_doc = another_account.api_docs_services.new(valid_attributes)
    api_doc.service = service
    refute api_doc.valid?
    assert_includes api_doc.errors[:service], 'not found'

    api_doc = account.api_docs_services.new(valid_attributes.merge({service_id: service.id + 1000}), without_protection: true)
    refute api_doc.valid?
    assert_includes api_doc.errors[:service], 'not found'
  end

  test 'scope accessible' do
    services = FactoryBot.create_list(:simple_service, 2, account: account)
    api_docs = []
    api_docs << account.api_docs_services.create!(valid_attributes.merge({name: 'accessible'})) # accessible without service
    api_docs << services.first.api_docs_services.create!(valid_attributes.merge({name: 'service-accessible'})) # accessible with service
    api_docs << services.last.api_docs_services.create!(valid_attributes.merge({name: 'service-deleted'})) # non-accessible wit service
    services.last.mark_as_deleted!
    assert_same_elements api_docs[0..1].map(&:id), ApiDocs::Service.accessible.pluck(:id)
  end

  test 'scope without_service' do
    api_docs_services = FactoryBot.create_list(:api_docs_service, 2)
    service = FactoryBot.create(:simple_service, account: api_docs_services.first.account)
    api_docs_services.first.update_column(:service_id, service.id)
    assert_equal [api_docs_services.last.id], ApiDocs::Service.without_service.pluck(:id)
  end

  test 'scope permitted_for' do
    permitted_service, forbidden_service = FactoryBot.create_list(:simple_service, 2, account: account)

    account_level_api_docs_service = FactoryBot.create(:api_docs_service, account: account, service: nil)
    permitted_api_docs_service = FactoryBot.create(:api_docs_service, account: account, service: permitted_service)
    forbidden_api_docs_service = FactoryBot.create(:api_docs_service, account: account, service: forbidden_service)

    member = FactoryBot.create(:member, account: account, admin_sections: ['partners'])
    member.member_permission_service_ids = [permitted_service.id]
    member.save!

    permitted_api_docs_service_ids = ApiDocs::Service.permitted_for(member).pluck(:id)
    assert_includes permitted_api_docs_service_ids, account_level_api_docs_service.id
    assert_includes permitted_api_docs_service_ids, permitted_api_docs_service.id
    assert_not_includes permitted_api_docs_service_ids, forbidden_api_docs_service.id

    all_api_docs_service_ids = ApiDocs::Service.permitted_for.pluck(:id)
    assert_same_elements [account_level_api_docs_service.id, permitted_api_docs_service.id, forbidden_api_docs_service.id], all_api_docs_service_ids
  end

  private

  def valid_attributes
    @valid_attributes ||= {name: 'name', body: '{"apis": [], "basePath": "http://example.com"}'}
  end

end
