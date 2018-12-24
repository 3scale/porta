Given 'I have following countries:' do |table|

  table.hashes.each do |country|
    FactoryBot.create(:country, :code => country[:code], :name => country[:name])
  end

end
