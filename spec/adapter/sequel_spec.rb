# frozen_string_literal: true

describe Cursed::Adapter::Sequel do
  include_examples 'a relational database adapter' do
    before { relation.import %i(cursor name), data }
    after { relation.delete }

    let(:relation) { DB[:widgets] }
  end
end
