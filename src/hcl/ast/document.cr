module HCL
  module AST
    class Document < Node
      getter :attributes, :blocks

      def initialize(
        peg_tuple : Pegmatite::Token,
        string : String,
        attributes : Hash(String, Node),
        blocks : Array(Block)
      )
        super(peg_tuple, string)

        @attributes = attributes
        @blocks = blocks
      end

      def to_s(io : IO)
        attributes.each do |key, value|
          io << key
          io << " = "
          value.to_s(io)
          io << "\n"
        end

        io << "\n" if attributes.any?

        blocks.each do |block|
          block.to_s(io)
          io << "\n"
        end
      end

      def value
        value(ExpressionContext.default_context)
      end

      def value(ctx : ExpressionContext) : ValueType
        dict = {} of String => ValueType

        attributes.each do |key, value|
          dict[key] = value.value(ctx).as(ValueType)
        end

        blocks.each do |block|
          block_dict = block.value(ctx).as(Hash(String, ValueType))
          dict.merge!(block_dict)
        end

        dict
      end
    end
  end
end
