class ApiClassificationService
  TEST_API_HOSTS = Set[*ThreeScale.config.sandbox_proxy.test_api_hosts].freeze

  attr_reader :test_hosts

  def initialize(test_hosts: TEST_API_HOSTS)
    @test_hosts = test_hosts
  end

  # @param [String] url
  # @return [Symbol] either `:real` or `:test`

  def test(url)
    uri = URI(url)

    host = uri.host

    Category.new(uri: uri, test_api: test_hosts.include?(host))
  end

  def self.test(uri)
    new.test(uri)
  end

  class Category
    attr_reader :uri

    def initialize(uri:, test_api:)
      @uri = uri.freeze
      @test_api = test_api
    end

    def real_api?
      ! test_api?
    end

    def test_api?
      @test_api
    end
  end
end
