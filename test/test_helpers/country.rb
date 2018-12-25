module TestHelpers
  module Country
    private

    def stub_countries
      Country.stubs(:all).returns([
        FactoryBot.build_stubbed(:country, :code => 'us', :name => 'United States of America'),
        FactoryBot.build_stubbed(:country, :code => 'es', :name => 'Spain')])
    end
  end
end

ActiveSupport::TestCase.send(:include, TestHelpers::Country)
