require 'tempfile'

module Apicast
  class ZipGenerator
    attr_reader :source, :generator

    def initialize(source)
      @source = source
      @generator = Apicast::ProviderPackageGenerator.new(source)
    end

    def filename
      "proxy_configs_#{source.id}.zip"
    end

    def each
      return enum_for unless block_given?

      generator.each do |name, contents|
        yield name, contents.call
      end
    end

    def data
      tmp = Tempfile.new(filename, encoding: 'binary')

      ::Zip::OutputStream.open(tmp) do |zip|
        each do |name, contents|
          zip.put_next_entry name
          zip.write contents
        end
      end

      tmp.flush
      tmp.open
    end
  end
end
