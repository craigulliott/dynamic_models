module DynamicModels

  # looks for object_id notation, and returns a new model
  def parent_model
    params.each do |name, value|
      if name =~ /(.+)_id$/
        return @parent_model ||= $1.camelize.constantize.find(value)
      end
    end
    nil
  end

  # model name from the controller
  def model_name
    params[:controller].split('/').last.singularize
  end
  
  # returns a new model, it can be set with an optional hash
  def new_model(defaults = {})
    new_model = model_name.camelize.constantize.new(defaults)
    new_model.send("#{parent_model.class.name.underscore}=", parent_model) if parent_model
    return new_model
  end

  # returns a model using the id from the params
  def fetch_model
    model_name.camelize.constantize.find( params[:id] )
  end

  # returns an array of models (using the name of this controller)
  def fetch_model_list
    if parent_model
      return parent_model.send("#{model_name.pluralize.downcase}")
    else
      return model_name.camelize.constantize.find(:all)
    end
  end

end

class ActionController::Base
  include DynamicModels
end
