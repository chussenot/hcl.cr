module HCL
  class Token::Block < Token
    getter :id, :args, :values, :blocks

    alias Value = NamedTuple(
      id: ::String,
      args: Array(::String),
      values: Hash(::String, HCL::ValueType),
      blocks: Array(Value)
    )

    def initialize(
      peg_tuple : Pegmatite::Token,
      string : ::String,
      id : ::String,
      args : Array(Token::String),
      values : Hash(::String, HCL::ValueToken),
      blocks : Array(Token::Block)
    )
      super(peg_tuple, string)

      @id = id
      @args = args
      @values = values
      @blocks = blocks
    end

    def value
      {
        id: id,
        args: args.map { |arg| arg.value },
        values: values_dict,
        blocks: blocks.map { |block| block.value.as(Value) }
      }
    end

    private def values_dict
      dict = {} of ::String => HCL::ValueType

      values.each do |key, value|
        dict[key] = value.value.as(HCL::ValueType)
      end

      dict
    end
  end
end
