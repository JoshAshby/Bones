# frozen_string_literal: true

describe Features do
  let(:config) { { "feature_flags" => { "test_false" => false, "test_true" => true } } }

  before do
    allow(described_class).to receive(:config).and_return config
  end

  it "returns true for enabled strings" do
    expect(described_class).to be_enabled("test_true")
  end

  it "returns true for enabled symbols" do
    expect(described_class).to be_enabled(:test_true)
  end

  it "returns false for disabled" do
    expect(described_class).not_to be_enabled(:test_false)
  end

  it "fails for unknown features" do
    expect { described_class.enabled?(:wut) }.to raise_error(Features::UnknownFeatureError)
  end
end
