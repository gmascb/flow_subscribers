module Flows
  class CompleteFlowSubscriber

    attr_accessor :flow_context
  
    # A place to validate if this flow can be executed
    # Needs to return a boolean
    def can_execute?(flow_context)
      puts "Can execute? #{self.to_s}"
    end
  
    # A place to validate things
    # Time to throw some exceptions from validations
    def valid?(flow_context)
      puts "Validating #{self.to_s}"
    end
  
    # A place to do things
    def prepare(flow_context) 
      puts "Preparing #{self.to_s}"
    end
  
    # A place to save your data objects
    def save(flow_context)
      puts "Saving #{self.to_s}"
    end
  
    # A place to finish things
    def dispose(flow_context)
      puts "Disposing #{self.to_s}"
    end

    def name
      self.class.name
    end

    def to_s
      self.name
    end
  end  
end
