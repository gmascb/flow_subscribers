# frozen_string_literal: true

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
      @flows.each do |flow|
        puts "Starting the SimpleFlow: #{flow.to_s}"
        flow.run(@flow_context)
        puts "Finished the SimpleFlow: #{flow.to_s}"
      end
      @flow_context
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

