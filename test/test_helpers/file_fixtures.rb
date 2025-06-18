# frozen_string_literal: true

ActiveSupport::TestCase.class_eval do
  include ActiveSupport::Testing::FileFixtures

  path = Rails.root.join('test/fixtures')
  self.fixture_paths = [path]
  self.file_fixture_path = path
end
