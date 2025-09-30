module ThreeScale
  module PrivateModule

    def PrivateModule(*modules)

      Module.new do
        @mods = modules.map(&:dup)

        def self.append_features(mod)
          @mods.each do |m|
            public_methods = mod.public_instance_methods
            mod.send(:include, m)
            added = mod.public_instance_methods - public_methods

            added.each do |method|
              mod.send(:private, method)
            end
          end
        end
      end
    end
  end
end
