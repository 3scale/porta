class InjectThemeStylesheetTagIntoLayouts < ActiveRecord::Migration
  def self.up
    #PageTemplate.find_each do |template|
    #  class << template
    #    def save!(perform_validations=false)
    #      save(perform_validations) || raise(ActiveRecord::RecordNotSaved.new(errors.full_messages))
    #    end
    #  end
    #  template.body = template.body.gsub(/\{\{\s*'\/css\/theme\.css'\s*\|\s*stylesheet_link_tag\s*\}\}/, '{% theme_stylesheet %}')
    #  template.save!
    #end
  end

  def self.down
    #PageTemplate.find_each do |template|
    #  template.body = template.body.gsub(/\{%\s*theme_stylesheet\s*%\}/, "{{ '/css/theme.css' | stylesheet_link_tag }}")
    #  template.save!
    #end
  end
end
