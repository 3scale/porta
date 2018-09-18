module Liquid
  module Drops
    extend self

    def documentation
      Liquid::Docs::Generator[ Base.descendants.map{|drop| [drop, drop.documentation]} ]
    end

    def load_all
      Dir[File.join('lib', 'developer_portal', 'lib', 'liquid', 'drops', '*.rb')].each do |drop|
        load File.expand_path(drop)
      end
    end
  end

end
