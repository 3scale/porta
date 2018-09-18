require 'test_helper'

class Liquid::Tags::ActiveDocsTest < ActiveSupport::TestCase

  test "syntax regexp" do

    {
      'version: "1.2"'                            => ['1.2'],
      'version:"1.0"'                             => ['1.0'],
      'version: "1.2" service:"foo,bar"'          => ['1.2','foo,bar'],
      'version: "1.0" services: "lambada, kings"' => ['1.0','lambada, kings'],
      'version:"2.0" service: "dudas"'            => ['2.0','dudas']
    }.each do | params, expected |
      match = params.match Liquid::Tags::ActiveDocs::Syntax
      assert match
      assert_equal match[1], expected[0]
      assert_equal match[2], expected[1]
    end
  end
end
