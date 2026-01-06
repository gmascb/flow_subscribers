require 'flow_subscribers'

RSpec.describe Flows::SimpleFlowController do
  it "has a version number" do
    expect(Flows::VERSION).not_to be nil
  end

  it "calling controller execute" do
    ctrl = Flows::SimpleFlowController.new(
      flows: [
        TestSimpleFlowSubscriber.new, 
        TestSimpleFlowSubscriber.new
      ],
      flow_context: { message: "My text" }
    )
    
    result = ctrl.execute
    expect(result[:message]).to eq("My text")
    expect(result[:executed_count]).to eq(2)
  end
end

class TestSimpleFlowSubscriber < Flows::SimpleFlowSubscriber
  def execute(flow_context)
    flow_context[:executed_count] ||= 0
    flow_context[:executed_count] += 1
  end
end
