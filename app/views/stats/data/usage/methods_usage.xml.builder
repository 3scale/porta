xml.instruct!

xml.usage do
  xml.period do
    xml.since       @methods[:period][:since]
    xml.until       @methods[:period][:until]
    xml.name        @methods[:period][:name]
    xml.granularity @methods[:period][:granularity].to_s
  end
  xml.metrics do
    @methods[:metrics].each do |method|
      xml.metric do
        xml.id method[:id]
        xml.name method[:name]
        xml.system_name method[:system_name]
        xml.unit method[:unit]
        xml.data do
          xml.total  method[:data][:total]
          xml.values(method[:data][:values].join(','), :length => method[:data][:values].size)
        end
      end
    end
  end
end