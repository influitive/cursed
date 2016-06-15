# frozen_string_literal: true

module Cursed
  # Cursor is a value object that has all the parameters required to determine
  # how to fetch a page of records using the cursor pattern.
  class Cursor
    DIRECTIONS = %i(forward backward).freeze

    attr_reader :after, :before, :limit, :maximum, :attribute, :direction

    # @param [Integer] after The cursor index to retrieve records after
    # @param [Integer] before The cursor index to retrive records before
    # @param [Integer] limit The maximum number of records to retrieve
    # @param [Integer] maximum The maximum value that :limit can have
    # @param [Symbol] attribute The name of the attribute to cursor upon
    # @param [:forward or :backward] direction The direction the cursor will advance in the collection
    def initialize(after: nil, before: nil, limit: 10, maximum: 20, attribute: :cursor, direction: :forward)
      @after = Integer(after) unless after.nil?
      @before = Integer(before) unless before.nil?
      @limit = Integer(limit)
      @maximum = Integer(maximum)
      @attribute = attribute
      @direction = direction
      raise ArgumentError, "#{direction} is not a valid direction" unless DIRECTIONS.include?(direction)
    end

    # returns the value of {#limit} clamped into the range of 1..{#maximum} (inclusive)
    def clamped_limit
      [1, limit, maximum].sort[1]
    end

    # returns true when the direction is forward
    def forward?
      direction == :forward
    end

    # returns true when the direction is backward
    def backward?
      direction == :backward
    end

    # returns true when the before parameter is set to a non-nil value
    def before?
      !before.nil?
    end

    # returns true when the after parameter is set to a non-nil value
    def after?
      !after.nil?
    end
  end
end
