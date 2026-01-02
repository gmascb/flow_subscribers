# frozen_string_literal: true

module Flows
  class SimpleCatchFlowSubscriber < SimpleFlowSubscriber
    # Overrides run to add try/catch around execute
    def run(flow_context)
      self.execute(flow_context)
    rescue Exception => e
      puts "Exception: #{e.message}"
      self.catch(e, flow_context)
    end

    # Method that the developer must implement
    def execute(flow_context)
      raise NotImplementedError, "#{self.class} must implement the execute method"
    end

    # Method called when an exception occurs
    def catch(exception, flow_context)
      raise NotImplementedError, "#{self.class} must implement the catch method"
    end
  end
end

