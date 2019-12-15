require "../../spec_helper"

describe HCL::Functions::Coalesce do
  describe "#matches_arity" do
    it "accepts one to #{HCL::Function::ARG_MAX} arguments" do
      fn = HCL::Functions::Concat.new

      fn.matches_arity?(0_u32).should eq(false)
      fn.matches_arity?(1_u32...HCL::Function::ARG_MAX).should eq(true)
      fn.matches_arity?(HCL::Function::ARG_MAX + 1).should eq(false)
    end
  end

  describe "#call" do
    it "returns the first non-null argument" do
      fn = HCL::Functions::Coalesce.new

      hsh = Hash(String, HCL::ValueType).new
      arr = Array(HCL::ValueType).new

      fn.call([hsh, "hello"]).should eq(hsh)
      fn.call([arr, nil]).should eq(arr)
      fn.call([
        nil.as(HCL::ValueType),
        "🧄".as(HCL::ValueType),
        "🧇".as(HCL::ValueType)
      ]).should eq("🧄")

      fn.call([
        nil.as(HCL::ValueType),
        nil.as(HCL::ValueType),
        nil.as(HCL::ValueType)
      ]).should be_nil

      some_hash = Hash(String, HCL::ValueType).new.tap do |hsh|
        hsh["one"] = 1_i64
        hsh["two"] = 2_i64
        hsh["three"] = 3_i64
      end
      fn.call([nil, some_hash]).should eq(some_hash)
    end
  end
end
