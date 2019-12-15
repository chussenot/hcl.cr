module HCL
  module Functions
    class Substr < Function
      def initialize
        super(
          name: "substr",
          arity: 3,
          varadic: false
        )
      end

      def call(args : Array(ValueType)) : ValueType
        str = args[0]
        offset = args[1]
        length = args[2]

        if !str.is_a?(String)
          raise ArgumentTypeError.new(
            "substr(str, offset, length): Argument type mismatch. Expected a string, but got #{str.class}."
          )
        end

        if !offset.is_a?(Int64)
          raise ArgumentTypeError.new(
            "substr(str, offset, length): Argument type mismatch. Expected an integer, but got #{offset.class}."
          )
        end

        if !length.is_a?(Int64)
          raise ArgumentTypeError.new(
            "substr(str, offset, length): Argument type mismatch. Expected an integer, but got #{length.class}."
          )
        end

        str[offset..(offset+length)]
      end
    end
  end
end
