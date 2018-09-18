class Provider::Admin::LiquidDocsController < Provider::Admin::BaseController
  include ApplicationHelper

  activate_menu! :topmenu => :help
  layout 'provider'

  def show
    generator = Liquid::Docs::Generator.new
    generator << File.new(Rails.root.join('doc','liquid',"_intro.md")).read

    %w( drops tags filters ).map do |type|
      generator << "# #{type.capitalize}\n"
      generator << File.new(Rails.root.join('doc','liquid',"#{type}.md")).read.gsub(/^#/, '##')
    end

    links = Rails.root.join('doc','liquid', "_links.md.erb")
    generator << ERB.new(File.read(links)).result(binding)

    @docs = generator.to_html.to_s.html_safe
  end
end
