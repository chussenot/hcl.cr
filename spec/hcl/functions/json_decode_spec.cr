require "../../spec_helper"

describe HCL::Functions::JSONDecode do
  describe "#matches_arity" do
    it "accepts one argument" do
      fn = HCL::Functions::JSONDecode.new

      fn.matches_arity?(0_u32).should eq(false)
      fn.matches_arity?(1_u32).should eq(true)
      fn.matches_arity?(2_u32..20_u32).should eq(false)
    end
  end

  describe "#call" do
    it "returns a deserialized representation of the value in ValueType" do
      fn = HCL::Functions::JSONDecode.new

      json = <<-JSON
      {"prop1":123,"prop2":"hello","prop3":{},"prop4":[0,1,2]}
      JSON

      hsh = Hash(String, HCL::ValueType).new
      hsh["prop1"] = HCL::ValueType.new(123_i64)
      hsh["prop2"] = HCL::ValueType.new("hello")
      hsh["prop3"] = HCL::ValueType.new(Hash(String, HCL::ValueType).new)
      hsh["prop4"] = HCL::ValueType.new([
        HCL::ValueType.new(0_i64),
        HCL::ValueType.new(1_i64),
        HCL::ValueType.new(2_i64)
      ])

      deserialized = fn.call([HCL::ValueType.new(json)])
      deserialized.should eq(HCL::ValueType.new(hsh))
      deserialized.unwrap.should eq({
        "prop1" => 123_i64,
        "prop2" => "hello",
        "prop3" => {} of String => HCL::ValueType::Types,
        "prop4" => [0_i64, 1_i64, 2_i64]
      })
    end
  end
end
