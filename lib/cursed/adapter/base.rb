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
end
