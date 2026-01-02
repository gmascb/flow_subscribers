module Flows
  class SimpleCatchFlowSubscriber < SimpleFlowSubscriber
    # Sobrescreve run para adicionar try/catch ao redor do execute
    def run(flow_context)
      self.execute(flow_context)
    rescue Exception => e
      puts "Exception: #{e.message}"
      self.catch(e, flow_context)
    end

    # Método que o desenvolvedor deve implementar (herdado, mas reforçando)
    def execute(flow_context)
      raise NotImplementedError, "#{self.class} must implement the execute method"
    end

    # Método chamado quando ocorre uma exceção
    def catch(exception, flow_context)
      raise NotImplementedError, "#{self.class} must implement the catch method"
    end
  end
end
