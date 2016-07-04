# frozen_string_literal: true

module Cursed
  module Adapter
    class Base
      attr_reader :relation

      def initialize(array)
        @relation = array
      end

      def apply_to(cursor)
        attr = cursor.attribute

        after(attr, cursor.after) if cursor.after?

        before(attr, cursor.before) if cursor.before?

        if cursor.forward?
          ascend_by(attr)
        else
          descend_by(attr)
        end

        limit(cursor.clamped_limit)

        relation
      end
    end
  end

  module_function

  def Adapter(value)
    case value
    when -> (x) { x.is_a?(Class) && x.ancestors.include?(Adapter::Base) } then value
    when Sequel::Dataset then Adapter::Sequel
    when ActiveRecord::Base, ActiveRecord::Relation then Adapter::ActiveRecord
    else raise ArgumentError, "unable to cast #{value.inspect} to Adapter"
    end
  end
end
