module HCL
  module AST
    class Block < Node
      @labels : Array(BlockLabel)

      getter :id, :labels, :attributes, :blocks

      def initialize(
        peg_tuple : Pegmatite::Token,
        string : String,
        id : String,
        labels : Array(BlockLabel),
        attributes : Hash(String, Node),
        blocks : Array(Block)
      )
        super(peg_tuple, string)

        @id = id
        @labels = labels
        @attributes = attributes
        @blocks = blocks
      end

      def to_s(io : IO)
        io << id
        io << " "

        if labels.any?
          labels.each do |label|
            label.to_s(io)
            io << " "
          end
        end

        io << "{\n"

        indent = "  "

        attributes.each do |key, value|
          io << indent
          io << "#{key} = "
          value.to_s(io)
          io << "\n"
        end

        if blocks.any?
          io << "\n" if attributes.any?

          blocks.each do |block|
            block_lines = block.to_s.split("\n")
            block_lines.each do |line|
              if line != ""
                io << indent
                io << line
                io << "\n"
              end
            end
          end
        end

        io << "}\n"
      end

      def value(ctx : ExpressionContext) : ValueType
        block_header = [id] + labels.map do |label|
          label.value(ctx)
        end
        block_value = value_dict(ctx)
        block_header.reverse.reduce(block_value) do |acc, val|
          if val.is_a?(ValueType)
            # TODO: When is this not the case?
            ValueType.new({ val.value.to_s => acc })
          else
            ValueType.new({ val.to_s => acc })
          end
        end
      end

      private def value_dict(ctx)
        dict = {} of String => ValueType

        attributes.each do |key, value|
          dict[key] = value.value(ctx)
        end

        blocks.each do |block|
          block_dict = block.value(ctx).value.as(Hash(String, ValueType))
          dict.merge!(block_dict)
        end

        ValueType.new(dict)
      end
    end
  end
end
