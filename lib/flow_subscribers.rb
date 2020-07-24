require "flow_subscribers/version"
require 'byebug'

module Flows
  class Error < StandardError; end

  class FlowSubscribers

    attr_accessor :flow_subscriber_context

    # A place to validate if this flow can be executed
    # Needs to return a boolean
    def can_execute?(obj)
      puts "Can execute? #{obj.to_s}"
      self.flow_subscriber_context = obj
    end

    # A place to validate things
    # Time to throw some exceptions from validations
    def valid?(obj)
      puts "Validating #{obj.to_s}"
      self.flow_subscriber_context = obj
    end

    # A place to do things
    def prepare(obj)
      puts "Preparing #{obj.to_s}"
      self.flow_subscriber_context = obj
    end

    # A place to save your data objects
    def save(obj)
      puts "Saving #{obj.to_s}"
      self.flow_subscriber_context = obj
    end

    # A place to finish things
    def dispose(obj)
      puts "Disposing #{obj.to_s}"
      self.flow_subscriber_context = obj
    end
  end

  class SubscriberController

    attr_accessor :subscriber_controller_context

    def initialize(obj)
      puts obj
      self.subscriber_controller_context = obj
    end

    def add_flow(flow)
      @flows = [] if @flows.nil?
      @flows << flow
      @flows.flatten!
    end

    def execute

      return if !@flows.is_a? Array || @flows.empty? || !@flows.try(:first).is_a?(FlowSubscribers)

      @flows.each do |flow|

        puts "Starting the FlowSubscribers: #{flow.to_s}"

        puts "Executing can_execute..."
        if flow.can_execute?(self.subscriber_controller_context)

          puts "Executing validations..."
          flow.valid?(self.subscriber_controller_context)

          puts "Executing prepare..."
          if flow.prepare(self.subscriber_controller_context)

            puts "Executing save..."
            flow.save(self.subscriber_controller_context)

          end
        end
      end

      @flows.each { |f| f.dispose(self.subscriber_controller_context) }

      self.subscriber_controller_context
    end
  end
end