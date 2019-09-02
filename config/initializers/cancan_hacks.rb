# frozen_string_literal: true

require 'cancan_hacks'
require 'cancan/ability/rules'

module CanCan
  module Ability
    Rules.module_eval do
      # possible_relevant_rules does not return `nil` values anymore
      def possible_relevant_rules(subject)
        if subject.is_a?(Hash)
          rules
        else
          positions = @rules_index.values_at(subject, *alternative_subjects(subject))
          positions.flatten!.sort!
          positions.map { |i| @rules[i] }.compact
        end
      end
    end
  end
end
