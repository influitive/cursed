# frozen_string_literal: true

module Cursed
  class Page
    include Enumerable

    def initialize(relation:, cursor:)
      @relation = relation
      @cursor = cursor
    end

    # Iterates through each element in the current page
    def each(*args, &block)
      collection.each(*args, &block)
    end

    # Invalidates the local cache of the current page - the next call to {#each}
    # (or any Enumerable method that calls it) will fetch a fresh page.
    def invalidate!
      @collection = nil
      @count = nil
    end

    # @return [Integer] the number of records in this page
    def count
      @count ||= @collection.try(:length) || relation.count
    end

    # @return [Boolean] if there are records on this page
    def any?
      count > 0
    end

    # @return [Integer] the maximum cursor index in the current page
    def maximum_id
      collection.map(&cursor.attribute).max
    end

    # @return [Integer] the minimum cursor index in the current page
    def minimum_id
      collection.map(&cursor.attribute).min
    end

    # Returns a hash of parameters which should be used for generating a next
    # page link.
    # @return [Hash] a hash containing any combination of :before, :after, :limit
    def next_page_params
      if cursor.forward?
        after_maximum_params
      else
        before_minimum_params
      end
    end

    # Returns a hash of parameters which should be used for generating a previous
    # page link.
    # @return [Hash] a hash containing any combination of :before, :after, :limit
    def prev_page_params
      if cursor.forward?
        before_minimum_params
      else
        after_maximum_params
      end
    end

    # @return [Cursor] with the values to fetch the next page
    def next_page_cursor
      params = next_page_params.merge(
        maximum: cursor.maximum,
        direction: cursor.direction,
        attribute: cursor.attribute
      )

      Cursor.new(params)
    end

    # @return [Cursor] with the values to fetch the previous page
    def prev_page_cursor
      params = prev_page_params.merge(
        maximum: cursor.maximum,
        direction: cursor.direction,
        attribute: cursor.attribute
      )

      Cursor.new(params)
    end

    private

    attr_reader :relation, :cursor

    def collection
      @collection ||= relation.to_a
    end

    def after_maximum_params
      { after: maximum_id || cursor.after, limit: cursor.clamped_limit }
    end

    def before_minimum_params
      { before: minimum_id || cursor.before, limit: cursor.clamped_limit }
    end
  end
end
