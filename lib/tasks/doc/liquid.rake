namespace :doc do
  namespace :liquid do

    def sort_classes(array)
      array.sort do |a,b|
        first = a.name.split('::').last
        second = b.name.split('::').last
        first <=> second
      end
    end

    def output(documented, file = ENV['FILE'])
      generator = Liquid::Docs::Generator.new

      documented.each do |item|
        generator << item.documentation
      end

      text = if ENV['HTML']
               generator.to_html
             else
               generator.to_markdown
            end

      if file = ENV['FILE']
        File.open(file, 'w'){|f| f << text}
      else
        puts(text)
      end
    end

    desc 'Re-generate all liquid docs'
    task :generate => :environment do
      extension = ENV['HTML'] ? 'html' : 'md'

      %w( drops tags filters ).each do |type|
        ENV['FILE'] = "doc/liquid/#{type}.#{extension}"
        Rake::Task["doc:liquid:#{type}"].invoke
      end
    end

    desc "Outputs documentation of our Liquid Drops in Markdown format. Optionaly you can pass FILE."
    task :drops => [:environment] do
      Liquid::Drops.load_all

      all = sort_classes(Liquid::Drops::Base.descendants)

      to_skip = [ # Deprecated
                  Liquid::Drops::Buyer,
                  Liquid::Drops::Site,
                  Liquid::Drops::Menu,
                  Liquid::Drops::NewSignup,
                  # Hidden
                  Liquid::Drops::User::Can,
                  Liquid::Drops::CurrentUser::Can,
                  Liquid::Drops::Application::Oauth,
                  Liquid::Drops::Plan,
                  Liquid::Drops::Errors::Message,
                  Liquid::Drops::ContentOf,
                  Liquid::Drops::Fields,
                  Liquid::Drops::Field::Choice,
                  Liquid::Drops::Model ]

      output(all - to_skip)
    end

    desc "Outputs documentation of our Liquid Tags in Markdown format. Optionaly you can pass FILE to redirect output."
    task :tags => [:environment] do
      # ancestors of Liquid::Block
      blocks = [ Liquid::Tags::Email, Liquid::Tags::ContentFor, Liquid::Tags::Form ]
      all = sort_classes(Liquid::Tags::Base.subclasses + blocks)

      to_skip =  [
                   # Deprecated tags:
                   Liquid::Tags::EssentialAssets,
                   Liquid::Tags::Container,
                   Liquid::Tags::CreditCardMissing,
                   Liquid::Tags::InternalError,
                   Liquid::Tags::PaymentGatewayBaseForm,
                   Liquid::Tags::PageSection,
                   Liquid::Tags::ThemeStylesheet,
                   Liquid::Tags::TrialNotice,
                   Liquid::Tags::PageSubSection ]

      output(all - to_skip)
    end

    desc "Outputs documentation for our Liquid Filters in Markdown format."
    task :filters => [:environment] do
      Liquid::Tags.load_all

      filters = [ Liquid::Filters::FormHelpers,
                  Liquid::Filters::ParamFilter,
                  Liquid::Filters::RailsHelpers,
                  # Deprecated:
                  # Liquid::Filters::UrlHelpers
                ]

      output(filters)
    end

  end
end
