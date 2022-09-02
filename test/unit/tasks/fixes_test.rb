# frozen_string_literal: true

require 'test_helper'

module Tasks
  class FixesTest < ActiveSupport::TestCase
    attr_reader :tmpfile

    setup do
      @tmpfile = Tempfile.new(%w[logo- .image])
    end

    test 'regenerate JPEG logos :invoice style' do
      profile = FactoryBot.create(:profile)
      profile.logo.post_processing = false
      file_fixture("hypnotoad.jpg").open("rb") { |io| profile.logo = io }
      profile.save!

      assert_raises(Errno::ENOENT) { profile.logo.copy_to_local_file :invoice, tmpfile.path }

      execute_rake_task 'fixes.rake', 'fixes:regenerate_jpeg_invoice_logo'
      profile.logo.copy_to_local_file :invoice, tmpfile.path
    end

    test "regenerate JPEG logos ignores pngs" do
      profile = FactoryBot.create(:profile)
      profile.logo.post_processing = false
      file_fixture("small.png").open("rb") { |io| profile.logo = io }
      profile.save!

      execute_rake_task 'fixes.rake', 'fixes:regenerate_jpeg_invoice_logo'
      assert_raises(Errno::ENOENT) { profile.logo.copy_to_local_file :invoice, tmpfile.path }
    end

    test "regenerate JPEG logos ignores gifs" do
      profile = FactoryBot.create(:profile)
      profile.logo.post_processing = false
      file_fixture("hypnotoad.jpg").open("rb") { |io| profile.logo = io }
      profile.save!
      profile.update_column(:logo_content_type, "image/gif")

      execute_rake_task 'fixes.rake', 'fixes:regenerate_jpeg_invoice_logo'
      assert_raises(Errno::ENOENT) { profile.logo.copy_to_local_file :invoice, tmpfile.path }
    end

    test "report JPEG logos fix errors" do
      FactoryBot.create(:profile, logo_file_name: "fake.jpg", logo_content_type: "image/jpeg")
      Rails.logger.expects(:error).with { |val| val =~ /^Failed to reprocess invoice logo for.*/ }
      execute_rake_task 'fixes.rake', 'fixes:regenerate_jpeg_invoice_logo'
    end
  end
end
