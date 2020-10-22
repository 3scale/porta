# frozen_string_literal: true

Given "{buyer} is not charged monthly" do |buyer|
  buyer.not_paying_monthly!
end

Given "{buyer} is not billed monthly" do |buyer|
  buyer.not_paying_monthly!
end
