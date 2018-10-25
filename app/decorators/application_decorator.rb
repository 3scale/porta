class ApplicationDecorator < Draper::Decorator
  delegate_all
  
  self.include_root_in_json = true
end
