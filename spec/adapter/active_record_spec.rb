# frozen_string_literal: true

describe Cursed::Adapter::ActiveRecord do
  include_examples 'a relational database adapter' do
    before { data.each { |cursor, name| Widget.create(cursor: cursor, name: name) } }
    after { Widget.delete_all }

    let(:relation) { Widget.unscoped }
  end
end
