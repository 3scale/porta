ActiveSupport.on_load(:active_record) do

ActiveRecord::Base.class_eval do
  public :initialize_dup
end

end
