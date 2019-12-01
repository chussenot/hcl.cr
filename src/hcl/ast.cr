module HCL
  module AST
    alias Operand =
      Literal |
      Number |
      Expression
    alias ValueType =
      Nil |
      Bool |
      String |
      Int64 |
      Float64 |
      Hash(String, ValueType) |
      Array(ValueType)
  end
end
