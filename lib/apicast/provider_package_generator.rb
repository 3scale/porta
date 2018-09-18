module Apicast
  class ProviderPackageGenerator
    # @param [Apicast::ProviderSource] source
    def initialize(source)
      @source = source
    end

    README = Rails.root.join('lib', 'proxy', 'readme.txt')
    LICENSE = Rails.root.join('lib', 'proxy', 'license.txt')

    OAUTH_GENERATORS = Apicast::GENERATORS

    # @yield [filename, contents] Calls the block with filename and contents block.
    # @yieldparam filename [String] name of the file to write to
    # @yieldparam contents [Proc] callable to get the file contents
    def each
      return enum_for unless block_given?

      yield nginx_conf, -> { Apicast::ProviderNginxGenerator.new.emit(source) }
      yield lua_file, -> { Apicast::ProviderLuaGenerator.new.emit(source) }

      yield 'readme.txt', -> { README.read }
      yield 'license.txt', -> { LICENSE.read }


      if needs_oauth_helpers?
        OAUTH_GENERATORS.each do |generator|
          yield generator.filename, -> { generator.emit(source) }
        end
      end

      self
    end

    def nginx_conf
      "nginx_#{source.id}.conf"
    end

    def lua_file
      "nginx_#{source.id}.lua"
    end

    def needs_oauth_helpers?
      Array(source.services).any? { |service| service.backend_version == 'oauth' }
    end

    protected

    attr_reader :source
  end
end
