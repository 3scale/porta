module TestHelpers
  module StubChain
    # Allows to stub chained method. Example:
    #
    #   Article.stub_chain(:published, :latest, :featured).returns([@article])
    #
    # will stub calls to:
    #
    #   Article.published.latest.featured
    #
    # and return @article
    def stub_chain(*names)
      fake_chain(:stubs, *names)
    end

    # Like stub_chain, but the last link of the chain is mocked, not stubbed.
    def expect_chain(*names)
      fake_chain(:expects, *names)
    end

    def fake_chain(method, *names)
      if names.length > 1
        name   = names.shift
        result = Mocha::Mockery.instance.named_mock("result of #{name}")

        stubs(name).returns(result)
        result.fake_chain(method, *names)
      else
        send(method, names.first)
      end
    end
  end
end

Object.send(:include, TestHelpers::StubChain)
