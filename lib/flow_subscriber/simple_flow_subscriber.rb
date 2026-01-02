module Flows
  class SimpleFlowSubscriber
    
    attr_accessor :flow_context

    def initialize(flow_context: {})
      @flow_context = flow_context
    end

    # Método chamado pelo controller - não sobrescrever
    def run(flow_context)
      execute(flow_context)
    end

    # Método que o desenvolvedor deve implementar
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