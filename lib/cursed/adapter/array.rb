# frozen_string_literal: true

module Cursed
  module Adapter
    class Array < Base
      def descend_by(attribute)
        relation.sort_by!(&attribute)
        relation.reverse!
      end

      def ascend_by(attribute)
        relation.sort_by!(&attribute)
      end

      def limit(count)
        @relation = relation.take(count)
      end

      def after(attribute, value)
        relation.select! { |x| x.public_send(attribute) > value }
      end

      def before(attribute, value)
        relation.select! { |x| x.public_send(attribute) < value }
      end
    end
  end
end
