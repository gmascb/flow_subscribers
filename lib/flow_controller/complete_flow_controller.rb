require "flow_subscribers/version"
require 'byebug'

module Flows
  class CompleteFlowController

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
        puts "Starting the CompleteFlow: #{flow.to_s}"

        puts "Executing can_execute? #{flow.to_s}"
        if flow.can_execute?(self.flow_context)
          
          puts "Executing valid? #{flow.to_s}"
          flow.valid?(self.flow_context)
          
          puts "Executing prepare #{flow.to_s}"
          if flow.prepare(self.flow_context)
            puts "Executing save #{flow.to_s}"
            flow.save(self.flow_context)
          end
        end
      end

      @flows.each do |flow|
        puts "Executing dispose #{flow.to_s}"
        flow.dispose(self.flow_context)
      end

      @flow_context
    end

    def validate_flows!
      if !@flows.is_a? Array || @flows.empty?
        @flows.each do |flow|
          raise "Flows must be an array of CompleteFlowSubscribers" unless flow.is_a?(CompleteFlowSubscriber)
        end
      end
    end
  end
end