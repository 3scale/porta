require 'test_helper'

class ApiAuthentication::ByAccessTokenTest < ActiveSupport::TestCase

  class AlaskaController < ActionController::Base
    include ApiAuthentication::ByAccessToken
  end

  def test_access_token_scopes
    assert AlaskaController.access_token_scopes = :finance
    assert AlaskaController.access_token_scopes = %i[finance stats]

    assert_raise(ApiAuthentication::ByAccessToken::ScopeError) do
      AlaskaController.access_token_scopes = :wild
    end
    assert_raise(ApiAuthentication::ByAccessToken::ScopeError) do
      AlaskaController.access_token_scopes = :wild, :finance
    end
  end
end
