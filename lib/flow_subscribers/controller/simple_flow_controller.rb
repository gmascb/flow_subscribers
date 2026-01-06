# frozen_string_literal: true

module Flows
  class SimpleFlowController
    attr_accessor :flows, :flow_context

    def initialize(flows:, flow_context:, transactional: false)
      @flows = flows
      @flow_context = flow_context
      @transactional = transactional
    end

    # Method called externally or by parent controllers - standardized interface
    def run(flow_context)
      @flow_context = flow_context
      execute
    end

    def execute
      validate_flows!

      if @transactional
        ActiveRecord::Base.transaction do
          execute_flows
        end
      else
        execute_flows
      end
    end

    def execute_flows
      @flows.each do |flow|
        puts "Starting the SimpleFlow: #{flow.to_s}"
        @flow_context = flow.run(@flow_context)
        puts "Finished the SimpleFlow: #{flow.to_s}"
      end
      @flow_context
    end

    def validate_flows!
      raise "Flows must be an array" unless @flows.is_a?(Array)
      raise "Flows array cannot be empty" if @flows.empty?
      
      @flows.each do |flow|
        unless flow.is_a?(SimpleFlowSubscriber) || flow.is_a?(SimpleFlowController)
          raise "All flows must be SimpleFlowSubscriber or SimpleFlowController instances"
        end
      end
    end
  end
end

