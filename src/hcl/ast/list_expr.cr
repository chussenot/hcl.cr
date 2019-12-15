module HCL
  module AST
    class List < Node
      getter :children

      def initialize(peg_tuple : Pegmatite::Token, string : String)
        super(peg_tuple, string)
        @children = [] of Node
      end

      def <<(node : Node)
        @children << node
      end

      def to_s(io : IO)
        io << "["
        children.each_with_index do |node, index|
          node.to_s(io)

          if index != (children.size - 1)
            io << ", "
          end
        end

        io << "]"
      end

      def value(ctx : ExpressionContext) : ValueType
        children.map do |item|
          item.value(ctx).as(ValueType)
        end
      end
    end
  end
end