xml.instruct!
xml.usage do
  xml.metric do
    xml.id @data[:metric][:id]
    xml.name @data[:metric][:name]
    xml.system_name @data[:metric][:system_name]
    xml.unit @data[:metric][:unit]
  end
  xml.period do
    xml.since @data[:period][:since]
    xml.until @data[:period][:until]
    xml.name @data[:period][:name]
    xml.granularity @data[:period][:granularity].to_s
  end
  xml.data do
    xml.total @data[:total]
    xml.values(@data[:values].join(','), :length => @data[:values].size)
  end
  unless @cinstance.nil?
    application = @data[:application]
    xml.application do
      xml.id      application[:id]
      xml.name    application[:name]
      xml.plan do
        xml.id    application[:plan][:id]
        xml.name  application[:plan][:name]
      end
      xml.account do
        xml.name  application[:account][:name]
        xml.id    application[:account][:id]
      end
    end
  end
end