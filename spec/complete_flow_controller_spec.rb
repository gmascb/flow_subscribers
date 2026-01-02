require 'flow_subscribers'

RSpec.describe Flows do
  it "has a version number" do
    expect(Flows::VERSION).not_to be nil
  end

  before(:all){
    @ctrl = Flows::CompleteFlowController.new(
      [
        Flows::CompleteFlowSubscriber.new, 
        Flows::CompleteFlowSubscriber.new
      ], 
      { flow_context: "My text" }
    )
  }

  it "calling controller execute" do
    result = @ctrl.execute
    expect(result[:flow_context].is_a?(String)).to be_truthy
  end

end
