# frozen_string_literal: true

Given "{buyer} has customized plan" do |buyer|
  buyer.bought_cinstance.customize_plan!
end
