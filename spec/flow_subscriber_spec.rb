require 'flow_subscribers'

RSpec.describe Flows do
  it "has a version number" do
    expect(Flows::VERSION).not_to be nil
  end

  before(:each){

    @ctrl = Flows::SubscriberController.new("My text")
    flow1 = Flows::FlowSubscribers.new
    flow2 = Flows::FlowSubscribers.new

    @ctrl.add_flow(flow1)
    @ctrl.add_flow(flow2)

  }

  it "calling controller execute" do
    r = @ctrl.execute
    expect(r.is_a?(String)).to be_truthy
  end

end
