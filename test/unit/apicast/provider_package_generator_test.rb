class Apicast::ProviderPackageGeneratorTest < ActiveSupport::TestCase

  def test_nginx_conf
    provider = FactoryGirl.build_stubbed(:simple_provider)
    source = Apicast::ProviderSource.new(provider)
    generator = Apicast::ProviderPackageGenerator.new(source)

    assert_equal "nginx_#{provider.id}.conf", generator.nginx_conf
  end

  def needs_oauth_helpers?
    source = Apicast::ProviderSource.new(mock('provider'))
    source.expects(services: [ OpenStruct.new(backend_version: 'oauth', proxy: true) ]).at_least_once
    generator = Apicast::ProviderPackageGenerator.new(source)

    assert generator.needs_oauth_helpers?
  end

  def test_lua_file
    provider = FactoryGirl.build_stubbed(:simple_provider)
    source = Apicast::ProviderSource.new(provider)
    generator = Apicast::ProviderPackageGenerator.new(source)

    assert_equal "nginx_#{provider.id}.lua", generator.lua_file
  end

  def test_each_enumerator
    provider = FactoryGirl.build_stubbed(:simple_provider)
    source = Apicast::ProviderSource.new(provider)
    generator = Apicast::ProviderPackageGenerator.new(source)

    assert_kind_of Enumerator, generator.each
    assert_equal generator, generator.each{}
  end

  def test_each_keys
    provider = FactoryGirl.build_stubbed(:simple_provider)
    source = Apicast::ProviderSource.new(provider)
    generator = Apicast::ProviderPackageGenerator.new(source)

    subject = generator.each.to_h.keys

    assert_equal 4, subject.size
    assert_includes subject, generator.nginx_conf
    assert_includes subject, generator.lua_file
    assert_includes subject, 'readme.txt'
  end

  def test_each_values
    provider = FactoryGirl.build_stubbed(:simple_provider)
    source = Apicast::ProviderSource.new(provider)
    generator = Apicast::ProviderPackageGenerator.new(source)

    subject = generator.each.to_h.values

    assert_equal 4, subject.size

    subject.each do |content|
      assert_kind_of Proc, content
    end
  end

  def test_each_oauth_keys
    provider = FactoryGirl.build_stubbed(:simple_provider)
    source = Apicast::ProviderSource.new(provider)
    service = OpenStruct.new(proxy: OpenStruct.new, backend_version: 'oauth')
    source.expects(services: [ service ]).at_least_once
    generator = Apicast::ProviderPackageGenerator.new(source)

    subject = generator.each.to_h.keys

    assert_equal 8, subject.size
    assert_includes subject, 'authorize.lua'
    assert_includes subject, 'get_token.lua'
    assert_includes subject, 'threescale_utils.lua'
    assert_includes subject, 'authorized_callback.lua'
  end
end
