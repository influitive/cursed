# frozen_string_literal:true

describe Cursed::Collection do
  subject { described_class.new(relation: relation, cursor: cursor, adapter: adapter) }

  let(:cursor) { Cursed::Cursor.new(before: before, after: after, limit: limit) }

  let(:adapter) { Cursed::Adapter::Array }

  let(:relation) do
    [
      double(cursor: 5, id: 3),
      double(cursor: 3, id: 7),
      double(cursor: 6, id: 4),
      double(cursor: 2, id: 1)
    ]
  end

  let(:limit) { 2 }

  let(:after) { 2 }

  let(:before) { nil }

  describe '#current_page' do
    subject { super().current_page.to_a.map(&:cursor) }

    it { is_expected.to match_array [3, 5] }
  end

  describe '#prev_page' do
    subject { super().prev_page.to_a.map(&:cursor) }

    it { is_expected.to eq [2] }
  end

  describe '#next_page' do
    subject { super().next_page.to_a.map(&:cursor) }

    it { is_expected.to eq [6] }
  end

  describe '#next_page?' do
    subject { super().next_page? }

    context 'when there are records in the next page' do
      it { is_expected.to eq true }
    end

    context 'when there are no records in the next page' do
      let(:after) { 100 }
      it { is_expected.to eq false }
    end
  end

  describe '#prev_page?' do
    subject { super().prev_page? }

    context 'when there are records in the previous page' do
      it { is_expected.to eq true }
    end

    context 'when there are no records in the previous page' do
      let(:before) { 0 }
      it { is_expected.to eq false }
    end
  end
end
