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
      @flows.each do |flow|
        flow.flow_context["#{flow.to_s}_can_execute?".to_sym] = flow.can_execute?(flow.flow_context)
      end

      @flows.each do |flow|
        if flow.flow_context["#{flow.to_s}_can_execute?".to_sym] == true
          begin
            flow.valid?(flow.flow_context)
          rescue Exception => e
            flow.flow_context["#{flow.to_s}_validation_error_message".to_sym] = e.message
            raise CompleteFlowValidationException(e.message)
          end
        end
      end

      # prepare the flows
      @flows.each do |flow|
        if flow.flow_context["#{flow.to_s}_can_execute?".to_sym] == true
          puts "Executing prepare #{flow.to_s}"
          flow.prepare(flow.flow_context)
        end
      end

      # save the flows
      @flows.each do |flow|
        if flow.flow_context["#{flow.to_s}_can_execute?".to_sym] == true
          puts "Executing save #{flow.to_s}"
          flow.save(flow.flow_context)
        end
      end

      # dispose the flows
      @flows.each do |flow|
        if flow.flow_context["#{flow.to_s}_can_execute?".to_sym] == true
          puts "Executing dispose #{flow.to_s}"
          flow.dispose(flow.flow_context)
        end
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