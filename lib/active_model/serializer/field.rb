module ActiveModel
  class Serializer
    # Holds all the meta-data about a field (i.e. attribute or association) as it was
    # specified in the ActiveModel::Serializer class.
    # Notice that the field block is evaluated in the context of the serializer.
    Field = Struct.new(:name, :options, :block) do
      # Compute the actual value of a field for a given serializer instance.
      # @param [Serializer] The serializer instance for which the value is computed.
      # @return [Object] value
      #
      # @api private
      #
      def value(serializer)
        if block
          serializer.instance_eval(&block)
        else
          serializer.read_attribute_for_serialization(name)
        end
      end

      # Decide whether the field should be serialized by the given serializer instance.
      # @param [Serializer] The serializer instance
      # @return [Bool]
      #
      # @api private
      #
      def included?(serializer)
        case condition_type
        when :if
          serializer.public_send(condition)
        when :unless
          !serializer.public_send(condition)
        else
          true
        end
      end

      private

      def condition_type
        @condition_type ||= begin
          if options.key?(:if)
            :if
          elsif options.key?(:unless)
            :unless
          else
            :none
          end
        end
      end

      def condition
        options[condition_type]
      end
    end
  end
end
