require "../../spec_helper"

describe HCL::Functions::SetUnion do
  describe "#matches_arity" do
    it "accepts two to #{HCL::Function::ARG_MAX} arguments" do
      fn = HCL::Functions::SetUnion.new

      fn.matches_arity?(0_u32...1_u32).should eq(false)
      fn.matches_arity?(2_u32...HCL::Function::ARG_MAX).should eq(true)
      fn.matches_arity?(HCL::Function::ARG_MAX + 1).should eq(false)
    end
  end

  describe "#call" do
    it "returns the union of all arguments" do
      fn = HCL::Functions::SetUnion.new

      arr1 = [
        HCL::ValueType.new("🧄"),
        HCL::ValueType.new("🧇")
      ]
      arr2 = [
        HCL::ValueType.new("hello"),
        HCL::ValueType.new(1_i64),
        HCL::ValueType.new("🧇")
      ]
      arr3 = [
        HCL::ValueType.new("world"),
        HCL::ValueType.new(true),
        HCL::ValueType.new("🧇")
      ]

      fn.call([
        HCL::ValueType.new(arr1),
        HCL::ValueType.new(arr2),
        HCL::ValueType.new(arr3)
      ]).raw.should eq([
        HCL::ValueType.new("🧄"),
        HCL::ValueType.new("🧇"),
        HCL::ValueType.new("hello"),
        HCL::ValueType.new(1_i64),
        HCL::ValueType.new("world"),
        HCL::ValueType.new(true)
      ])
    end

    it "raises an error if passed non-array arguments" do
      fn = HCL::Functions::SetUnion.new

      expect_raises(
        HCL::Function::ArgumentTypeError,
        "setunion(sets...): Argument type mismatch. Expected an array, but got String"
      ) do
        arr = HCL::ValueType.new([
          HCL::ValueType.new("🧄"),
          HCL::ValueType.new("🧇")
        ])

        fn.call([arr, HCL::ValueType.new("hello")])
      end
    end
  end
end
