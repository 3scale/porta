require 'test_helper'

class Apicast::ZipGeneratorTest < ActiveSupport::TestCase

  def test_source
    source = Apicast::ProviderSource.new(mock('provider'))

    subject = Apicast::ZipGenerator.new(source)

    assert_equal source, subject.source
  end

  def test_filename
    provider = FactoryBot.build_stubbed(:simple_provider)
    provider.id = 42
    source = Apicast::ProviderSource.new(provider)

    subject = Apicast::ZipGenerator.new(source)

    assert_equal 'proxy_configs_42.zip', subject.filename
  end

  def test_data
    provider = FactoryBot.build_stubbed(:simple_provider)
    provider.id = 42
    source = Apicast::ProviderSource.new(provider)

    subject = Apicast::ZipGenerator.new(source)

    assert File.readable?(subject.data), 'file should be readable'
    assert File.file?(subject.data), 'file should be a file'

    file = Tempfile.create('zip')
    FileUtils.copy_stream(subject.data, file)

    entries = Zip::File.open(file) do |zip|
      zip.each do |entry|
        assert entry.name
        assert entry.get_input_stream.read
      end
    end

    assert_equal %w(nginx_42.conf nginx_42.lua readme.txt license.txt), entries.keys
  end

  def test_each
    provider = FactoryBot.build_stubbed(:simple_provider)
    source = Apicast::ProviderSource.new(provider)

    subject = Apicast::ZipGenerator.new(source).each.to_h

    assert_equal %W(nginx_#{provider.id}.conf nginx_#{provider.id}.lua readme.txt license.txt), subject.keys
  end

  def test_generator
    source = Apicast::ProviderSource.new(mock('provider'))

    subject = Apicast::ZipGenerator.new(source)

    assert_kind_of Apicast::ProviderPackageGenerator, subject.generator
  end
end
