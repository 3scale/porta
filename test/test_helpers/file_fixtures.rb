# frozen_string_literal: true

ActiveSupport::TestCase.class_eval do
  include ActiveSupport::Testing::FileFixtures

  self.fixture_path = Rails.root.join('test/fixtures')
  self.file_fixture_path = fixture_path
end
