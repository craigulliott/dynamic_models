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

  # plural form of the model name from the controller
  def plural_model_name
    params[:controller].split('/').last
  end
  
  # returns a new model, it can be set with an optional hash
  def new_model(defaults = {})
    if parent_model
      # is it a has_many
      if parent_model.respond_to?(plural_model_name)
        new_model = parent_model.send(plural_model_name).build(defaults)
      # is is a has_one
      elsif parent_model.respond_to?(model_name)
        new_model = parent_model.send(model_name).build(defaults)
      else
        raise "can't find association #{model_name} or #{plural_model_name} for #{parent_model.class.name}"
      end
    else
      new_model = model_name.camelize.constantize.new(defaults)
    end
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
