require 'flow_subscribers'

RSpec.describe Flows::CompleteFlowController do
  it "has a version number" do
    expect(Flows::VERSION).not_to be nil
  end

  it "executes all phases in order" do
    ctrl = Flows::CompleteFlowController.new(
      [
        TestCompleteFlowSubscriber.new, 
        TestCompleteFlowSubscriber.new
      ], 
      { message: "My text", execution_order: [] }
    )

    result = ctrl.execute
    
    expect(result[:message]).to eq("My text")
    # Verify phase-based execution order
    expect(result[:execution_order]).to eq([
      "can_execute_1", "can_execute_2",
      "valid_1", "valid_2",
      "prepare_1", "prepare_2",
      "save_1", "save_2",
      "dispose_1", "dispose_2"
    ])
  end

  it "stops execution when validation fails" do
    ctrl = Flows::CompleteFlowController.new(
      [
        TestCompleteFlowSubscriber.new,
        FailingValidationFlowSubscriber.new
      ],
      { execution_order: [] }
    )

    expect { ctrl.execute }.to raise_error("Validation failed!")
  end
end

class TestCompleteFlowSubscriber < Flows::CompleteFlowSubscriber
  @@counter = 0

  def initialize
    @@counter += 1
    @id = @@counter
  end

  def can_execute?(flow_context)
    flow_context[:execution_order] << "can_execute_#{@id}"
    true
  end

  def valid?(flow_context)
    flow_context[:execution_order] << "valid_#{@id}"
  end

  def prepare(flow_context)
    flow_context[:execution_order] << "prepare_#{@id}"
  end

  def save(flow_context)
    flow_context[:execution_order] << "save_#{@id}"
  end

  def dispose(flow_context)
    flow_context[:execution_order] << "dispose_#{@id}"
  end
end

class FailingValidationFlowSubscriber < Flows::CompleteFlowSubscriber
  def can_execute?(flow_context)
    true
  end

  def valid?(flow_context)
    raise "Validation failed!"
  end
end
