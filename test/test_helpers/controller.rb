module TestHelpers
  module Controller
    private

    # Set host to specified value, e.g.: www.example.org.
    def host!(host)
      @request.host = host
    end
  end
end

ActionController::TestCase.send(:include, TestHelpers::Controller)
