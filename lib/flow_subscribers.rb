# frozen_string_literal: true

require "flow_subscribers/version"
require "flow_subscribers/subscriber/simple_flow_subscriber"
require "flow_subscribers/subscriber/simple_catch_flow_subscriber"
require "flow_subscribers/subscriber/complete_flow_subscriber"
require "flow_subscribers/controller/simple_flow_controller"
require "flow_subscribers/controller/complete_flow_controller"

module Flows
  class Error < StandardError; end
end
