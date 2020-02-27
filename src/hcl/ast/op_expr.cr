module HCL
  module AST
    class OpExpr < Node
      getter :operator, :left_operand, :right_operand

      ADDITION    = :+
      SUBTRACTION = :-
      MULTIPLY    = :*
      DIVIDE      = :/
      MOD         = :%
      EQ          = :==
      NEQ         = :"!="
      LT          = :<
      GT          = :>
      GTE         = :>=
      LTE         = :<=
      AND         = :"&&"
      OR          = :"||"
      NOT         = :"!"

      def initialize(
        operator : String,
        left_operand : Node,
        right_operand : Node?,
        **kwargs
      )
        super(**kwargs)

        @operator = case operator
                    when "+"  then ADDITION
                    when "-"  then SUBTRACTION
                    when "*"  then MULTIPLY
                    when "/"  then DIVIDE
                    when "%"  then MOD
                    when "==" then EQ
                    when "!=" then NEQ
                    when "<"  then LT
                    when ">"  then GT
                    when ">=" then GTE
                    when "<=" then LTE
                    when "&&" then AND
                    when "||" then OR
                    when "!"  then NOT
                    else
                      raise "BUG: unsupported operator: #{operator}"
                    end
        @left_operand = left_operand
        @right_operand = right_operand
      end

      def to_s(io : IO)
        if right_operand.nil?
          io << operator
          left_operand.to_s(io)
        else
          left_operand.to_s(io)
          io << " "
          io << operator
          io << " "
          right_operand.not_nil!.to_s(io)
        end
      end

      def value(ctx : ExpressionContext) : Any
        # This is wrong. Need to figure out order of operations stuff, probably.
        left_op = left_operand
        right_op = right_operand
        if right_op.nil?
          left_op = left_operand
          left_op_val = left_op.value(ctx).raw
          raise "Parser bug: Cannot perform unary operation on array" if left_op_val.responds_to?(:[])
          result = case operator
                   when NOT
                     !left_op_val
                   when SUBTRACTION
                     raise "Parser bug: Cannot perform numeric inversion on nil" if left_op_val.nil?
                     raise "Parser bug: Cannot perform numeric inversion on boolean" if left_op_val.is_a?(Bool)
                     -left_op_val
                   end

          Any.new(result)
        else
          left_op_val = left_op.value(ctx).raw
          right_op_val = right_op.value(ctx).raw

          result = case operator
                   when ADDITION
                     left_op_val, right_op_val = assert_number!(left_op_val, right_op_val)
                     left_op_val + right_op_val
                   when SUBTRACTION
                     left_op_val, right_op_val = assert_number!(left_op_val, right_op_val)
                     left_op_val - right_op_val
                   when MULTIPLY
                     left_op_val, right_op_val = assert_number!(left_op_val, right_op_val)
                     left_op_val * right_op_val
                   when DIVIDE
                     left_op_val, right_op_val = assert_number!(left_op_val, right_op_val)
                     left_op_val / right_op_val
                   when MOD
                     left_op_val, right_op_val = assert_number!(left_op_val, right_op_val)
                     if left_op_val.is_a?(Float64) && right_op_val.is_a?(Float64)
                       left_op_val % right_op_val
                     elsif left_op_val.is_a?(Int64) && right_op_val.is_a?(Int64)
                       left_op_val % right_op_val
                     else
                       raise "Parser bug: Cannot perform modulo operation on different types"
                     end
                   when EQ
                     left_op_val, right_op_val = assert_number!(left_op_val, right_op_val)
                     left_op_val == right_op_val
                   when NEQ
                     left_op_val, right_op_val = assert_number!(left_op_val, right_op_val)
                     left_op_val != right_op_val
                   when LT
                     left_op_val, right_op_val = assert_number!(left_op_val, right_op_val)
                     left_op_val < right_op_val
                   when GT
                     left_op_val, right_op_val = assert_number!(left_op_val, right_op_val)
                     left_op_val > right_op_val
                   when LTE
                     left_op_val, right_op_val = assert_number!(left_op_val, right_op_val)
                     left_op_val <= right_op_val
                   when GTE
                     left_op_val, right_op_val = assert_number!(left_op_val, right_op_val)
                     left_op_val >= right_op_val
                   when AND
                     left_op_val && right_op_val
                   when OR
                     left_op_val || right_op_val
                   end

          Any.new(result)
        end
      end

      private def assert_number!(left_op_val, right_op_val)
        raise "Parser bug: Cannot perform #{operator} operation on array" if left_op_val.responds_to?(:[])
        raise "Parser bug: Cannot perform #{operator} operation on array" if right_op_val.responds_to?(:[])
        raise "Parser bug: Cannot perform #{operator} operation on boolean" if left_op_val.is_a?(Bool)
        raise "Parser bug: Cannot perform #{operator} operation on boolean" if right_op_val.is_a?(Bool)
        raise "Parser bug: Cannot perform #{operator} operation on nil" if left_op_val.nil?
        raise "Parser bug: Cannot perform #{operator} operation on nil" if right_op_val.nil?
        {left_op_val, right_op_val}
      end
    end
  end
end