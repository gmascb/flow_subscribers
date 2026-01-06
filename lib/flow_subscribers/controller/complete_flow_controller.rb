# frozen_string_literal: true

module Flows
  class CompleteFlowController
    attr_accessor :flows, :flow_context, :transactional

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
      executable_flows = []
      @flows.each do |flow|
        puts "Checking can_execute? #{flow.to_s}"
        can_execute = flow.can_execute?(@flow_context)
        @flow_context["#{flow.to_s}_can_execute?".to_sym] = can_execute
        executable_flows << flow if can_execute
      end

      # If any validation fails, stop execution before save
      executable_flows.each do |flow|
        puts "Validating #{flow.to_s}"
        begin
          flow.valid?(@flow_context)
        rescue Exception => e
          @flow_context["#{flow.to_s}_validation_error".to_sym] = e.message
          raise e
        end
      end

      # Phase 3: prepare - Prepare all executable subscribers
      executable_flows.each do |flow|
        puts "Preparing #{flow.to_s}"
        flow.prepare(@flow_context)
      end

      # Phase 4: save - Save all executable subscribers
      # Only executed if all validations and preparations passed
      executable_flows.each do |flow|
        puts "Saving #{flow.to_s}"
        flow.save(@flow_context)
      end

      # Phase 5: dispose - Cleanup all executable subscribers
      executable_flows.each do |flow|
        puts "Disposing #{flow.to_s}"
        flow.dispose(@flow_context)
      end

      @flow_context
    end

    def validate_flows!
      raise "Flows must be an array" unless @flows.is_a?(Array)
      raise "Flows array cannot be empty" if @flows.empty?
      
      @flows.each do |flow|
        unless flow.is_a?(CompleteFlowSubscriber)
          raise "All flows must be CompleteFlowSubscriber instances"
        end
      end
    end
  end

  class CompleteFlowValidationException < StandardError; end
end

