module Pdf
  class Format
    extend ERB::Util

    def self.prep_td(data)
      data.map{|d| "<td>#{h(d.to_s)}</td>"}
    end

    def self.prep_td_with_negation(data)
      data.map do |d|
        if d =~ /\%/
          if d.to_f < 0
          "<td><red>#{d}</red></td>"
          elsif d.to_f > 0
            "<td><green>#{d}</green></td>"
          else
            "<td>#{d}</td>"
          end
        else
          "<td>#{d}</td>"
        end
      end
    end

    def self.prep_th(data)
      data.map{|v| "<th>#{CGI.escapeHTML(v)}</th>"}
    end
  end
end
