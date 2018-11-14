# frozen_string_literal: true

require 'test_helper'

class DeleteProvidedAccessTokensWorkerTest < ActiveSupport::TestCase
  test 'deletes long expired tokens' do
    relation = ProvidedAccessToken.long_expired
    ProvidedAccessToken.expects(:long_expired).returns(relation)
    relation.expects(:delete_all)
    DeleteProvidedAccessTokensWorker.new.perform
  end
end
