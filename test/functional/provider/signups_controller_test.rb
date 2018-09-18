require 'test_helper'

class Provider::SignupsControllerTest < ActionController::TestCase

  def setup
    @request.host = master_account.domain
    Account.any_instance.stubs(:signup_provider_possible?).returns(true)
    extra_fields = [
      {name: 'API_Status_3s__c', target: "Account", label: "At What Stage is your API Project?"},
      {name: 'API_Purpose_3s__c', target: "Account", label: "What is the purpose of your API?"},
      {name: 'API_Onprem_3s__c', target: "Account", label: "Are you interested in 3scale on-premises?"},
    ]
    extra_fields.each do |field|
      FieldsDefinition.create!(:account => master_account, :name => field[:name], :target => 'Account', :label => field[:label])
    end
  end

  def set_modified_since_header(date)
    System::Application.config.expects(boot_time: Time.now)

    @request.env['HTTP_IF_MODIFIED_SINCE'] = date.httpdate
  end

  test 'visit success page should not fail' do
    get :success
    assert_response :success
  end

  REQUIRED_FIELDS = %w{ account[user][email] account[user][password]
                        account[org_name] account[subdomain]
                        account[self_subdomain]
                        account[extra_fields][Signup_origin] }.freeze

  OPTIONAL_FIELDS = %w{
    account[user][first_name] account[user][last_name]
    account[extra_fields][API_Status_3s__c]
    account[extra_fields][API_Purpose_3s__c]
    account[extra_fields][API_Onprem_3s__c]
  }.freeze

  DEFAULT_FIELDS = (REQUIRED_FIELDS + OPTIONAL_FIELDS).map(&:freeze).freeze

  test 'render default fields when no fields parameters were set' do
    get :show
    assert_response :success
    required_inputs = DEFAULT_FIELDS

    assert_select 'input[name]' do |inputs|
      input_names = inputs.map{|i| i['name'] }.grep(/account/)
      assert_equal required_inputs.sort,
                    input_names.sort
    end

  end

  test 'render required fields + custom fields' do
    requested_fields = %w[
                  account[user][first_name] account[user][last_name]
                  account[#user][extra_fields][API_Status_3s__c]
                  account[extra_fields][API_Purpose_3s__c]
                ]

    parsed_requested_fields = requested_fields.map do |field|
      if field =~ /\[#user\]\[extra_fields\]/
        field.sub(/\[#user\]/, "")
      else
        field
      end
    end

    get :show, fields: requested_fields
    assert_response :success
    required_inputs = REQUIRED_FIELDS + parsed_requested_fields

    assert_select 'input[name]' do |inputs|
      input_names = inputs.map{|i| i['name'] }.grep(/account/)
      assert_equal required_inputs.sort,
                    input_names.sort
    end

  end

  test 'visit signups page, same parameters should set the same ETag header' do
    params = {origin_signup: 'test'}

    first_response_etag =  get(:show, params).etag
    second_response_etag =  get(:show, params).etag

    assert_equal first_response_etag, second_response_etag
  end

  test 'visit signups page, different parameters should not set the same ETag header' do
    first_response_etag =  get(:show, {origin_signup: 'test'}).etag
    second_response_etag =  get(:show, {fields: DEFAULT_FIELDS, origin_signup: 'test'}).etag
    third_response_etag =  get(:show, {fields: DEFAULT_FIELDS, origin_signup: 'another-test'}).etag

    assert_not_equal first_response_etag, second_response_etag
    assert_not_equal first_response_etag, third_response_etag
    assert_not_equal second_response_etag, third_response_etag
  end

  test 'when Last-Modified header is older than If-Modified-since date, response should be cached' do
    set_modified_since_header(12.hours.from_now)

    get :show

    assert_response :not_modified
  end

  test 'when If-Modified-since header is older than Last-Modified date, response should not be cached' do
    set_modified_since_header(12.hours.ago)

    get :show

    assert_response :success
  end

  test 'options should not execute the action' do
    @controller.expects(:show).never
    process :show, 'OPTIONS'
  end

  test 'options should execute the action cors' do
    @controller.expects(:cors).once
    process :show, 'OPTIONS'
  end
end
