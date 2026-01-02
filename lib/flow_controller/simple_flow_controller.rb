module Flows
  class SimpleFlowController
    attr_accessor :flows, :flow_context

    def initialize(flows, flow_context)
      @flows = flows
      @flow_context = flow_context
    end

    def execute
      validate_flows!
      execute_flows
    end

    def execute_flows
      result = nil
      @flows.each do |flow|
        puts "Starting the SimpleFlow: #{flow.to_s}"
        result = flow.execute(@flow_context)
        puts "Finished the SimpleFlow: #{flow.to_s}"
      end
      [result, @flow_context]
    end

    def validate_flows!
      if !@flows.is_a? Array || @flows.empty?
        @flows.each do |flow|
          raise "Flows must be an array of SimpleFlows" unless flow.is_a?(SimpleFlow)
        end
      end
    end
  end
end