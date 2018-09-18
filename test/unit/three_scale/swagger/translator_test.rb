require 'test_helper'

class ThreeScale::Swagger::TranslatorTest < ActiveSupport::TestCase

  test 'add schemes from basePath' do
    active_doc =<<-EOJSON
{
  "basePath": "http://example.net",
  "apiVersion":"1.0.0",
  "swaggerVersion":"1.2",
  "apis":[
    {
      "path":"/pet",
      "description":"Operations about pets"
    }
  ]
}
    EOJSON

    translated = ThreeScale::Swagger::Translator.translate!(active_doc).as_json
    assert_equal ['http'], translated["schemes"]


  end

  test "apis without operations" do
    active_doc =<<-EOJSON
{
  "apiVersion":"1.0.0",
  "swaggerVersion":"1.2",
  "apis":[
    {
      "path":"/pet",
      "description":"Operations about pets"
    }
  ]
}
    EOJSON

    assert_kind_of Hash, ThreeScale::Swagger::Translator.translate!(active_doc).as_json

  end

  test "multiple operations" do
    active_doc =<<-EOJSON
    {
      "swaggerVersion" : "1.2",
      "basePath": "http://yaio.com",
      "apis": [
        {
          "path": "/users",
          "operations": [
            {
              "method": "GET",
              "parameters": []
            },
            {
              "method": "POST",
              "parameters": [
                {
                  "paramType": "body",
                  "name": "body"
                }
              ]
            }
          ]
        },
        {
          "path": "/user/{id}",
          "operations": [
            {
              "method" : "GET",
              "parameters": [
                {
                  "paramType": "path",
                  "name": "id"
                }
              ]
            },
            {
              "httpMethod": "PUT",
              "parameters": [
                {
                  "paramType": "path",
                  "name": "id"
                },
                {
                  "paramType": "form",
                  "name": "name"
                }
              ]
            }
          ]
        }
      ]
    }
    EOJSON

    swagger= ThreeScale::Swagger::Translator.translate!(active_doc).as_json

    swagger['apis'].map{|e|e['operations']}.flatten.each do |op|
      assert op['nickname']
    end

    assert_equal 1, swagger['__notifications'].grep(/httpMethod/).size
  end

  test "translator translates" do
    active_doc =<<-EOJSON
    {
      "basePath": "https://echo-api.3scale.net",
      "apiVersion": "v1",
      "apis": [{
        "path": "/",
        "operations": [{
          "httpMethod": "GET",
          "summary": "Say Hello!",
          "description": "<p>This operation says hello.</p>",
          "group": "words",
          "parameters": [{
            "name": "user_key",
            "description": "Your API access key",
            "dataType": "string",
            "paramType": "query",
            "threescale_name": "user_keys"
          }]
        }]
      }]
    }
    EOJSON

    swagger = ThreeScale::Swagger::Translator.translate!(active_doc).as_json
    scope_params = swagger["apis"][0]["operations"][0]["parameters"][0]
    assert_equal 'user_keys', scope_params["x-data-threescale-name"]

    assert_equal "1.2", swagger['swaggerVersion']
  end

  # Regression test for https://github.com/3scale/system/issues/5709
  test "translator not raise error if no apis" do
    active_doc =<<-EOJSON
    {
      "basePath": "https://echo-api.3scale.net",
      "apiVersion": "v1"
    }
    EOJSON

    ThreeScale::Swagger::Translator.translate!(active_doc).as_json
  end
end
