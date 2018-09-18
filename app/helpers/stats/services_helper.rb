module Stats::ServicesHelper

  def render_methods_pages(methods, page_size)
    result = ''

    methods.each_slice(page_size).with_index do |page,i|
      style = (i == 0) ? '' : "display:none;"

      result += content_tag( :ul, :class => 'panel', :id => "panel_#{i.to_i}", :style => style) do
        page.inject('') do |memo,method|
          memo + render(:partial => '/stats/method', :object => method)
        end
      end
    end

    result
  end


end
