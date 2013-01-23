require 'dynamic_model_active_record_extensions'

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

  # if we are using a type parameter, then we are dealing with an STI model
  def sti_model?
    params[:type].present?
  end

  # model name from the controller or type parameter (for a model which is using STI)
  def model_name
    sti_model? ? params[:type].underscore : base_model_class_name
  end

  # the model class, inferred from the controller
  def base_model_class_name
    params[:controller].split('/').last.singularize
  end

  def base_model_class
    base_model_class_name.camelize.constantize
  end

  # the class we are working with, if an STI model then it will fail loudly on a type which inst descendant from the class which corresponds to this controller
  def model_class
    klass = model_name.camelize.constantize
    klass
  end

  # plural form of the model name from the controller
  def plural_model_name
    params[:controller].split('/').last
  end
  
  # returns a new model, it can be set with an optional hash
  def new_model(defaults = {})
    new_model = model_class.new(defaults)
    # if there is a parent then associate it with the model
    if parent_model
      new_model.send("#{parent_model.class.name.underscore}=", parent_model)
    end
    # return the new model
    new_model
  end

  # returns a model using the id from the params
  def fetch_model
    model_class.find params[:id]
  end

  # returns an array of models (using the name of this controller)
  def fetch_model_list
    if parent_model
      return parent_model.send("#{model_name.pluralize.downcase}")
    else
      return model_class.find(:all)
    end
  end

end

class ActionController::Base
  include DynamicModels
end

class ActiveRecord::Base
  include DynamicModelActiveRecordExtensions
end

