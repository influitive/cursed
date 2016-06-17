# frozen_string_literal: true

module Cursed
  class Collection
    include Enumerable

    attr_reader :relation, :cursor, :adapter

    # @param relation [ActiveRecord::Relation or Sequel::Dataset] the relation to cursor on
    # @param cursor [Cursor] the value object containing parameters for the cursor
    # @param adapter [Adapter] an object which plays the Adapter role
    def initialize(relation:, cursor:, adapter: nil)
      @relation = relation
      @cursor = cursor
      @adapter = adapter || determine_adapter(relation)
    end

    # Iterates through each element in the current page
    def each(*args, &block)
      collection.each(*args, &block)
    end

    # Invalidates the local cache of the current page - the next call to {#each}
    # (or any Enumerable method that calls it) will fetch a fresh page.
    def invalidate!
      @collection = nil
    end

    # Returns the maximum cursor index in the current page
    def maximum_id
      collection.map(&cursor.attribute).max
    end

    # Returns the minimum cursor index in the current page
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

    private

    def collection
      @collection ||= adapter.new(relation).apply_to(cursor).to_a
    end

    def determine_adapter(relation)
      case relation
      when Sequel::Dataset then Adapter::Sequel
      when ActiveRecord::Base, ActiveRecord::Relation then Adapter::ActiveRecord
      else raise ArgumentError, "unable to determine adapter for #{relation.inspect}"
      end
    end

    def after_maximum_params
      { after: maximum_id, limit: cursor.clamped_limit }
    end

    def before_minimum_params
      { before: minimum_id, limit: cursor.clamped_limit }
    end
  end
end
