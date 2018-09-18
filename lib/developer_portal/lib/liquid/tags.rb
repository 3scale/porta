# -*- coding: utf-8 -*-
module Liquid
  module Tags
    extend self

    def register(klass, template)
      template.register_tag klass.tag, klass
    end

    def load_all
      Dir[File.join('lib', 'liquid', 'tags', '*.rb')].each do |drop|
        load File.expand_path(drop)
      end
    end

  end
end
