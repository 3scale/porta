module UserDataHelpers
  private

  def stub_user_data(user_data, stubbed_method:  :user_data)
    user_data = ThreeScale::OAuth2::UserData.new(user_data)
    ThreeScale::OAuth2::ClientBase.any_instance.expects(stubbed_method).returns(user_data)
  end
end
