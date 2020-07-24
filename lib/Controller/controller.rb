# class SubscriberController
#
#   @flows = []
#   @context = nil
#
#   def initialize(*args)
#     @context = args
#   end
#
#   def add_flow(flow)
#     @flows << flow
#     @flows.flatten!
#   end
#
#   def execute
#
#     return if !@flows.is_a? Array || @flows.empty? || !@flows.try(:first).is_a?(FlowSubscribers)
#
#     @flows.each do |flow|
#
#       puts "Executing the FlowSubscribers: #{flow.to_s}"
#
#       puts "Executing can_execute"
#       if flow.can_execute(@context)
#
#         puts "Executing prepare"
#         if flow.prepare(@context)
#
#           puts "Executing save"
#           flow.save(@context)
#
#         end
#       end
#     end
#   end
# end