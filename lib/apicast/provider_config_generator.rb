module Apicast
  class ProviderConfigGenerator
    # @param [Apicast::ProviderSource] source
    def initialize(source)
      @source = source
    end


    # @yield [filename, contents] Calls the block with filename and contents block.
    # @yieldparam filename [String] name of the file to write to
    # @yieldparam contents [Proc] callable to get the file contents
    def each
      return enum_for unless block_given?

      yield spec_file, -> { source.attributes_for_proxy.to_json }

      self
    end

    def spec_file
      'spec.json'
    end

    protected

    attr_reader :source
  end
end
