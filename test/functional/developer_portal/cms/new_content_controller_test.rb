require 'test_helper'

class DeveloperPortal::CMS::NewContentControllerTest < DeveloperPortal::ActionController::TestCase
  def setup
    @provider = Factory(:simple_provider, state: 'approved')
    host! @provider.domain

    section = FactoryGirl.create(:root_cms_section, provider: @provider)
    @page = FactoryGirl.create(:cms_page, provider: @provider, section: section, published: 'foo')
  end

  test 'disabled when account is suspended' do
    @provider.update_columns(state: 'suspended')
    get :show, path: @page.path

    assert_response :not_found
  end

  test 'serve published page' do
    get :show, path: @page.path

    assert_response :success
    assert_equal 'foo', @response.body
  end

  test 'file from s3' do
    default_options = Paperclip::Attachment.default_options
    Paperclip::Attachment.stubs(default_options: default_options.merge(storage: :s3))

    file = FactoryGirl.create(:cms_file, provider: @provider)

    get :show, path: file.path

    assert_response :redirect
  end
end
