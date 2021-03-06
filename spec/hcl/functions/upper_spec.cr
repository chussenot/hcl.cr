require "../../spec_helper"

describe HCL::Functions::Upper do
  describe "#matches_arity" do
    it "accepts one argument" do
      fn = HCL::Functions::Upper.new

      fn.matches_arity?(0_u32).should eq(false)
      fn.matches_arity?(1_u32).should eq(true)
      fn.matches_arity?(2_u32..20_u32).should eq(false)
    end
  end

  describe "#call" do
    it "returns uppercase variant of string" do
      fn = HCL::Functions::Upper.new

      fn.call([HCL::Any.new("scream")]).should eq("SCREAM")
      fn.call([HCL::Any.new("ALREADY_UPPER")]).should eq("ALREADY_UPPER")
    end

    it "raises an error when passed something other than a string" do
      fn = HCL::Functions::Upper.new

      [
        nil,
        123_i64,
        123.456_f64,
        true,
        Hash(String, HCL::Any).new,
        Array(HCL::Any).new,
      ].each do |val|
        expect_raises(
          HCL::Function::ArgumentTypeError,
          "upper(str): Argument type mismatch. Expected a string, but got #{val.class}."
        ) do
          fn.call([HCL::Any.new(val)])
        end
      end
    end
  end
end
