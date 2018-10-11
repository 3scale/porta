# frozen_string_literal: true

require 'test_helper'

module ServiceDiscovery
  class ClusterServiceSpecificationTest < ActiveSupport::TestCase
    setup do
      @spec = ClusterServiceSpecification.new('http://example.com/api/doc')
      @spec.stubs(fetch: true)
    end

    test 'oas?' do
      @spec.expects(:type).returns('application/vnd.oai.openapi+json')
      assert @spec.oas?

      @spec.expects(:type).returns('application/xml')
      refute @spec.oas?
    end
  end
end
