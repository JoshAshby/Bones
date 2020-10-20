# frozen_string_literal: true

describe Features do
  let(:config) { { "feature_flags" => { "test_false" => false, "test_true" => true } } }

  it "returns true for enabled strings" do
    Features.stub :config, config do
      expect(Features.enabled?("test_true")).must_equal true
    end
  end

  it "returns true for enabled symbols" do
    Features.stub :config, config do
      expect(Features.enabled?(:test_true)).must_equal true
    end
  end

  it "returns false for disabled" do
    Features.stub :config, config do
      expect(Features.enabled?(:test_false)).wont_equal true
    end
  end

  it "fails for unknown features" do
    Features.stub :config, config do
      expect { Features.enabled?(:wut) }.must_raise Features::UnknownFeatureError
    end
  end
end
