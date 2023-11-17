# frozen_string_literal: true

require 'test_helper'

module ThreeScale::SpamProtection::Checks

  class CountTest <  ActiveSupport::TestCase

    setup do
      @object = Object.new
      @subject = Count.new({ 'count' => {} })
    end

    attr_reader :subject, :object

    test "pass when the user tried less than ATTEMPTS times in less than PERIOD" do
      travel_to(Time.zone.now + COUNT_PERIOD - 5.seconds) do
        (COUNT_ATTEMPTS - 1).times do
          assert_equal 0, subject.probability(object)
        end
      end
    end

    test "detects a bot when the user tried more than ATTEMPTS times in less than PERIOD" do
      travel_to(Time.zone.now + COUNT_PERIOD - 5.seconds) do
        (COUNT_ATTEMPTS - 1).times do
          assert_equal 0, subject.probability(object)
        end
        assert_raise(ThreeScale::SpamProtection::Checks::SpamDetectedError) { subject.probability(object) }
      end
    end

    test "pass when the user tried more than ATTEMPTS times in more than PERIOD" do
      travel_to(Time.zone.now + COUNT_PERIOD - 5.seconds) do
        (COUNT_ATTEMPTS - 1).times do
          assert_equal 0, subject.probability(object)
        end
      end

      travel_to(Time.zone.now + COUNT_PERIOD + 5.seconds) do
        (COUNT_ATTEMPTS - 1).times do
          assert_equal 0, subject.probability(object)
        end
      end
    end

    test "pass after detecting a bot, when PERIOD restarts" do
      travel_to(Time.zone.now + COUNT_PERIOD - 5.seconds) do
        (COUNT_ATTEMPTS - 1).times do
          assert_equal 0, subject.probability(object)
        end
        assert_raise(ThreeScale::SpamProtection::Checks::SpamDetectedError) { subject.probability(object) }
      end

      travel_to(Time.zone.now + COUNT_PERIOD + 5.seconds) do
        (COUNT_ATTEMPTS - 1).times do
          assert_equal 0, subject.probability(object)
        end
      end
    end
  end
end
