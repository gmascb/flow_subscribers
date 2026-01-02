# frozen_string_literal: true

require "flow_subscribers/version"
require "flow_subscriber/simple_flow_subscriber"
require "flow_subscriber/simple_catch_flow_subscriber"
require "flow_subscriber/complete_flow_subscriber"
require "flow_controller/simple_flow_controller"
require "flow_controller/complete_flow_controller"

module Flows
  class Error < StandardError; end
end

