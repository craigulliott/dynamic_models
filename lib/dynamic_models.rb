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
    sti_model? ? params[:type].underscore : params[:controller].split('/').last.singularize
  end

  # the model class, inferred from the controller
  def base_model_class
    params[:controller].split('/').last.singularize.camelize.constantize
  end

  # the class we are working with, if an STI model then it will fail loudly on a type which inst descendant from the class which corresponds to this controller
  def model_class
    klass = model_name.camelize.constantize
    if sti_model?
      raise "you can only pass a type which descends from #{params[:controller]}" unless klass.sti_model? and klass.parent == base_model_class
    end
    klass
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
        new_model = parent_model.send("build_#{model_name}", defaults)
      else
        raise "can't find association #{model_name} or #{plural_model_name} for #{parent_model.class.name}"
      end
    else
      new_model = model_class.new(defaults)
    end
    return new_model
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

