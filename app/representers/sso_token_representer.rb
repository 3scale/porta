module SSOTokenRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource

  property :sso_url
  property :token

  def sso_url
    sso_url!
  end

  def token
    encrypted_token
  end
end
