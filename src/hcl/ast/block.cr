module HCL
  module AST
    class Block < Body
      @labels : Array(BlockLabel)

      getter :id, :labels

      def initialize(
        id : String,
        labels : Array(BlockLabel),
        attributes : Hash(String, Node),
        blocks : Array(Block),
        **kwargs
      )
        super(attributes, blocks, **kwargs)

        @id = id
        @labels = labels
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

      def block_header(ctx : ExpressionContext)
        Array(Any).new(labels.size + 1).tap do |arr|
          arr << Any.new(id)
          labels.each do |label|
            arr << label.value(ctx)
          end

          arr
        end
      end

      def value(ctx : ExpressionContext) : Any
        block_value = super(ctx)
        block_header(ctx).reverse.reduce(block_value) do |acc, val|
          Any.new({ val.to_s => acc })
        end
      end
    end
  end
end
