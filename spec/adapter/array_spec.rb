# frozen_string_literal: true

require 'ostruct'

describe Cursed::Adapter::Array do
  include_examples 'a relational database adapter' do
    let(:relation) { data.map { |d| OpenStruct.new(cursor: d[0], name: d[1]) } }
  end
end
