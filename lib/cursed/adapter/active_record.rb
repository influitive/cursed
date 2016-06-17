# frozen_string_literal: true

module Cursed
  module Adapter
    class ActiveRecord < Base
      def descend_by(attribute)
        @relation = relation.reorder(attribute => :desc)
      end

      def ascend_by(attribute)
        @relation = relation.reorder(attribute => :asc)
      end

      def limit(count)
        @relation = relation.limit(count)
      end

      def after(attribute, value)
        @relation = relation.where(relation.table[attribute].gt(value))
      end

      def before(attribute, value)
        @relation = relation.where(relation.table[attribute].lt(value))
      end
    end
  end
end
