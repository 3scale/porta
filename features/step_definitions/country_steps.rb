# frozen_string_literal: true

Given 'I have following countries:' do |table|
  table.hashes.each do |country|
    FactoryBot.create(:country, code: country[:Code], name: country[:Name])
  end
end
