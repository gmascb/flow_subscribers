require 'flow_subscribers'

RSpec.describe Flows do
  it "has a version number" do
    expect(Flows::VERSION).not_to be nil
  end

  it "calling controller execute success true" do
    @ctrl = CreateAccountController.new
    result = @ctrl.execute
    expect(result[:create_account]).to be_truthy
  end

  it "calling controller execute success false" do
    @ctrl = CreateAccountWithErrorController.new
    result = @ctrl.execute
    expect(result[:create_account]).to be_falsey
  end
end

class CreateAccountController < Flows::SimpleFlowController
  def initialize
    super(
      flows: [CreateAccountSimpleFlowSubscriber.new],
      flow_context: {}
    )
  end
end

class CreateAccountWithErrorController < Flows::SimpleFlowController
  def initialize
    super(
      flows: [CreateAccountCatchFlowSubscriber.new],
      flow_context: {}
    )
  end
end

class CreateAccountSimpleFlowSubscriber < Flows::SimpleFlowSubscriber
  def execute(flow_context)
    puts "Executing CreateAccountSimpleFlowSubscriber"
    flow_context[:create_account] = true
  end
end

class CreateAccountCatchFlowSubscriber < Flows::SimpleCatchFlowSubscriber
  def execute(flow_context)
    puts "Executing CreateAccountCatchFlowSubscriber"
    raise Exception.new("CreateAccountCatchFlowSubscriber error")
  end

  def catch(exception, flow_context)
    puts "Catching CreateAccountCatchFlowSubscriber"
    flow_context[:create_account] = false
  end
end