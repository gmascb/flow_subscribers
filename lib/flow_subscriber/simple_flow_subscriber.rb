module Flows
  class SimpleFlowSubscriber
    
    attr_accessor :flow_context

    def initialize(flow_context: {})
      @flow_context = flow_context
    end

    # Method called by the controller - DO NOT override
    def run(flow_context)
      execute(flow_context)
    end

    # Method that the developer must implement
    def execute(flow_context)
      raise NotImplementedError, "#{self.class} must implement the execute method"
    end

    def name
      self.class.name
    end

    def to_s
      self.name
    end
  end
end
