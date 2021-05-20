# frozen_string_literal: true

require 'test_helper'

class Provider::DomainsControllerTest < ActionDispatch::IntegrationTest
  def setup
    login! master_account
  end

  test 'disables x_frame_options header' do
    post recover_provider_domains_path
    refute_includes response.headers, 'X-Frame-Options'
  end
end
