# WARNING:
# this observer is not meant to be used
# it is just warning for future generations
# do not try this at home
#
# it actualy preloads almost all associations when generating xml and destroys load of tests
class WebHooksObserver < ActiveRecord::Observer

  module ToXmlCaching
    def cache_to_xml!
      @cached_to_xml = to_xml
    end

    def to_xml(options = {})
      if @cached_to_xml
        if builder = options[:builder]
          # remove xml instruct
          builder << @cached_to_xml.sub(/^(<\?.+?\?>\s*)/, '')
        else
          @cached_to_xml
        end
      else
        super
      end
    end
  end

  observe :account, :user, :cinstance

  def before_destroy(object)
    # cache to_xml of objects that are about to be destroyed
    object.extend(ToXmlCaching)
    object.cache_to_xml!
  end

end
