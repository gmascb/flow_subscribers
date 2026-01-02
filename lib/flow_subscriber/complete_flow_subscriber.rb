module Flows
  class CompleteFlowSubscriber

    attr_accessor :flow_context
  
    # A place to validate if this flow can be executed
    # Needs to return a boolean
    def can_execute?(obj,flow_context)
      puts "Can execute? #{obj.to_s}"
      self.flow_context = flow_context
    end
  
    # A place to validate things
    # Time to throw some exceptions from validations
    def valid?(obj, flow_context)
      puts "Validating #{obj.to_s}"
      self.flow_context = flow_context
    end
  
    # A place to do things
    def prepare(obj, flow_context)
      puts "Preparing #{obj.to_s}"
      self.flow_context = flow_context
    end
  
    # A place to save your data objects
    def save(obj, flow_context)
      puts "Saving #{obj.to_s}"
      self.flow_subscriber_context = flow_context
    end
  
    # A place to finish things
    def dispose(obj, flow_context)
      puts "Disposing #{obj.to_s}"
      self.flow_subscriber_context = flow_context
    end
  end  
end
