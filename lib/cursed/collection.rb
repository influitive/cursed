# frozen_string_literal: true

require 'forwardable'

module Cursed
  class Collection
    extend Forwardable
    include Enumerable

    def_delegators :current_page, :each, :maximum_id, :minimum_id, :next_page_params, :prev_page_params

    attr_reader :relation, :cursor, :adapter

    # @param relation [ActiveRecord::Relation or Sequel::Dataset] the relation to cursor on
    # @param cursor [Cursor] the value object containing parameters for the cursor
    # @param adapter [Adapter] an object which plays the Adapter role
    def initialize(relation:, cursor:, adapter: nil)
      @relation = relation
      @cursor = cursor
      @adapter = Cursed::Adapter(adapter || relation)
    end

    # invalidates the {#current_page}, {#next_page} and {#prev_page}
    # @see Page#invalidate!
    def invalidate!
      [prev_page, next_page, current_page].each(&:invalidate!)
    end

    # @return [Page] the current page
    def current_page
      @current_page ||= build_page(cursor)
    end

    # @return [Page] the page following this one
    def next_page
      @next_page ||= build_page(current_page.next_page_cursor)
    end

    # @return [Page] the page previous to this one
    def prev_page
      @prev_page ||= build_page(current_page.prev_page_cursor)
    end

    # @return [Boolean] true if there are records that follow records in the current page
    def next_page?
      next_page.any?
    end

    # @return [Boolean] true if there are records that preceede records in the current page
    def prev_page?
      prev_page.any?
    end

    private

    attr_reader :relation, :cursor, :adapter

    def build_page(cursor)
      Page.new(relation: adapter.new(relation.dup).apply_to(cursor), cursor: cursor)
    end
  end
end
