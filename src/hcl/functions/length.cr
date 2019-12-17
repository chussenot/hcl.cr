module HCL
  module Functions
    class Length < Function
      def initialize
        super(
          name: "length",
          arity: 1,
          varadic: false
        )
      end

      def call(args : Array(Any)) : Any
        coll = args[0].raw

        if !coll || coll.is_a?(Bool) || coll.is_a?(Int64) || coll.is_a?(Float64) || coll.is_a?(String)
          raise ArgumentTypeError.new(
            "length(coll): Argument type mismatch. Expected a collection, but got #{coll.class}."
          )
        end

        coll = coll.as(Array(Any) | Hash(String, Any))

        Any.new(coll.size.to_i64)
      end
    end
  end
end
