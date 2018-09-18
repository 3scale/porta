xml.instruct!
xml.top do
  xml.metric do
    xml.id          @data[:metric][:id]
    xml.name        @data[:metric][:name]
    xml.system_name @data[:metric][:system_name]
    xml.unit        @data[:metric][:unit]
  end
  xml.period do
    xml.name  @data[:period][:name]
    xml.since @data[:period][:since]
    xml.until @data[:period][:until]
  end
  xml.applications do
    @data[:applications].each do |application|
      xml.application do
        xml.value   application[:value]
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
end