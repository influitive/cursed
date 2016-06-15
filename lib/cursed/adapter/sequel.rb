# frozen_string_literal: true

module Cursed
  module Adapter
    class Sequel < Base
      def descend_by(attribute)
        @relation = relation.order(attribute).reverse
      end

      def ascend_by(attribute)
        @relation = relation.order(attribute)
      end

      def limit(count)
        @relation = relation.limit(count)
      end

      def after(attribute, value)
        @relation = relation.where(::Sequel.expr(attribute) > value)
      end

      def before(attribute, value)
        @relation = relation.where(::Sequel.expr(attribute) < value)
      end
    end
  end
end
