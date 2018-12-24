module TestHelpers
  module Country
    private

    def stub_countries
      Country.stubs(:all).returns([
        FactoryBot.stub(:country, :code => 'us', :name => 'United States of America'),
        FactoryBot.stub(:country, :code => 'es', :name => 'Spain')])
    end
  end
end

ActiveSupport::TestCase.send(:include, TestHelpers::Country)
