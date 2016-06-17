# frozen_string_literal: true

shared_examples 'a relational database adapter' do
  subject { adapter.relation.map { |r| r[:name] } }

  let(:adapter) { described_class.new(relation) }

  let(:relation) { raise 'please define a let named :relation' }

  let(:data) do
    [
      [1, 'Alice'],
      [2, 'Gary'],
      [3, 'Carl'],
      [4, 'Irene'],
      [5, 'Daniel'],
      [6, 'Bob'],
      [7, 'Frank'],
      [8, 'Jack'],
      [9, 'Edward'],
      [10, 'Harriet']
    ]
  end

  describe '#descend_by' do
    before { adapter.descend_by(:name) }

    it 'sorts by the attribute in descending order' do
      expect(subject).to eq %w(
        Jack
        Irene
        Harriet
        Gary
        Frank
        Edward
        Daniel
        Carl
        Bob
        Alice
      )
    end
  end

  describe '#ascend_by' do
    before { adapter.ascend_by(:name) }

    it 'sorts by the attribute in ascending order' do
      expect(subject).to eq %w(
        Alice
        Bob
        Carl
        Daniel
        Edward
        Frank
        Gary
        Harriet
        Irene
        Jack
      )
    end
  end

  describe '#limit' do
    before { adapter.limit(3) }

    it 'returns at most the number of records' do
      expect(subject).to eq %w(Alice Gary Carl)
    end
  end

  describe '#after' do
    before { adapter.after(:cursor, 7) }

    it 'only retrieves elements after the cursor' do
      expect(subject).to eq %w(Jack Edward Harriet)
    end
  end

  describe '#before' do
    before { adapter.before(:cursor, 3) }

    it 'only retrieves elements before the cursor' do
      expect(subject).to eq %w(Alice Gary)
    end
  end
end
