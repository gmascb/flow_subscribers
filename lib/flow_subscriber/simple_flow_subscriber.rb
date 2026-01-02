module Flows
  class SimpleFlow
    
    attr_accessor :flow_context

    def initialize(flow_context: {})
      @flow_context = flow_context
    end

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