require 'test_helper'

class Logic::NginxProxyTest < ActionController::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account)
  end

  def test_generate_proxy_zip
    assert @provider.generate_proxy_zip
  end

  def test_generate_proxy_zip_oauth
    @provider.services.update_all(backend_version: 'oauth')
    assert @provider.generate_proxy_zip
  end

  def test_deploy_production_apicast
    default_options = Paperclip::Attachment.default_options
    Paperclip::Attachment.stubs(default_options: default_options.merge(storage: :s3))

    CMS::S3.stubs(:bucket).returns('test-bucket-s3')

    @provider.proxy_configs = StringIO.new('lua')
    @provider.proxy_configs_conf = StringIO.new('conf')

    @provider.save!

    @provider.proxy_configs.s3_interface.client.stub_responses(:copy_object,
                                                               ->(request) {
        assert_equal 'test-bucket-s3', request.params[:bucket]
        assert_equal ".hosted_proxy/sandbox_proxy_#{@provider.id}.lua", request.params[:key]
        assert_equal "test-bucket-s3/.sandbox_proxy/sandbox_proxy_#{@provider.id}.lua", request.params[:copy_source]
    }, ->(request) {
        assert_equal 'test-bucket-s3', request.params[:bucket]
        assert_equal ".hosted_proxy_confs/sandbox_proxy_#{@provider.id}.conf", request.params[:key]
        assert_equal "test-bucket-s3/.sandbox_proxy_confs/sandbox_proxy_#{@provider.id}.conf", request.params[:copy_source]
    })

    assert @provider.deploy_production_apicast
  end
end
