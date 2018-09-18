module TestHelpers
  module FakeWeb
    module Transactions
      def fake_transaction_post
        ::FakeWeb.register_uri :post, fake_backend_url("/transactions.xml"), :status => [202], :content_type => CONTENT_TYPE, :body => ""
      end
    end
  end
end


