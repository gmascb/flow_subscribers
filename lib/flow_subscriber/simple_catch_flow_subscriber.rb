module Flows
  class SimpleCatchFlow < SimpleFlow
    def execute(flow_context)
      self.do_execute(flow_context)
    rescue Exception => e
      puts "Exception: #{e.message}"
      self.catch(e, flow_context)
    end

    def do_execute(flow_context)
      raise NotImplementedError, "#{self.class} must implement the do_execute method"
    end

    def catch(exception, flow_context)
      raise NotImplementedError, "#{self.class} must implement the catch method"
    end
  end
end