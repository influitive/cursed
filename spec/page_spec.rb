# frozen_string_literal: true

describe Cursed::Page do
  subject { page }

  let(:page) { described_class.new(relation: adapted_relation, cursor: cursor) }

  let(:adapted_relation) { Cursed::Adapter::Array.new(relation).apply_to(cursor) }

  let(:relation) do
    [
      double(cursor: 5, id: 3),
      double(cursor: 3, id: 7),
      double(cursor: 6, id: 4),
      double(cursor: 2, id: 1)
    ]
  end

  let(:cursor) do
    Cursed::Cursor.new(
      before: before,
      after: after,
      limit: limit,
      maximum: maximum,
      attribute: attribute,
      direction: forward ? :forward : :backward
    )
  end

  let(:attribute) { :cursor }

  let(:forward) { true }

  let(:limit) { 100 }

  let(:maximum) { limit }

  let(:after) { nil }

  let(:before) { nil }

  it { is_expected.to be_a(Enumerable) }

  describe '#initialize' do
    it 'works' do
      expect { subject }.not_to raise_error
    end

    its(:cursor) { is_expected.to eq cursor }
  end

  describe '#maximum_id' do
    subject { super().maximum_id }

    it { is_expected.to eq 6 }

    context 'when using a non-standard attribute' do
      let(:attribute) { :id }

      it { is_expected.to eq 7 }
    end
  end

  describe '#minimum_id' do
    subject { super().minimum_id }

    it { is_expected.to eq 2 }

    context 'when using a non-standard attribute' do
      let(:attribute) { :id }

      it { is_expected.to eq 1 }
    end
  end

  describe '#next_page_params' do
    subject { super().next_page_params }

    context 'when cursoring forward' do
      let(:forward) { true }

      it { is_expected.to eq(after: 6, limit: 100) }

      context 'when there are no elements on the page' do
        let(:after) { 100 }

        it { is_expected.to eq(after: 100, limit: 100) }
      end
    end

    context 'when cursoring backward' do
      let(:forward) { false }

      it { is_expected.to eq(before: 2, limit: 100) }

      context 'when there are no elements on the page' do
        let(:before) { 0 }

        it { is_expected.to eq(before: 0, limit: 100) }
      end
    end
  end

  describe '#prev_page_params' do
    subject { super().prev_page_params }

    context 'when cursoring forward' do
      let(:forward) { true }

      it { is_expected.to eq(before: 2, limit: 100) }

      context 'when there are no elements on the page' do
        let(:before) { 0 }

        it { is_expected.to eq(before: 0, limit: 100) }
      end
    end

    context 'when cursoring backward' do
      let(:forward) { false }

      it { is_expected.to eq(after: 6, limit: 100) }

      context 'when there are no elements on the page' do
        let(:after) { 100 }

        it { is_expected.to eq(after: 100, limit: 100) }
      end
    end
  end

  describe '#next_page_cursor' do
    subject { super().next_page_cursor }

    it { is_expected.to be_a Cursed::Cursor }

    context 'when cursoring forward' do
      let(:forward) { true }

      its(:after)     { is_expected.to eq 6 }
      its(:before)    { is_expected.to eq nil }
      its(:limit)     { is_expected.to eq 100 }
      its(:maximum)   { is_expected.to eq 100 }
      its(:attribute) { is_expected.to eq :cursor }
      its(:direction) { is_expected.to eq :forward }
    end

    context 'when cursoring backward' do
      let(:forward) { false }

      its(:after)     { is_expected.to eq nil }
      its(:before)    { is_expected.to eq 2 }
      its(:limit)     { is_expected.to eq 100 }
      its(:maximum)   { is_expected.to eq 100 }
      its(:attribute) { is_expected.to eq :cursor }
      its(:direction) { is_expected.to eq :backward }
    end

    context 'while using a non-standard attribute' do
      let(:attribute) { :id }

      its(:attribute) { is_expected.to eq :id }
    end
  end

  describe '#prev_page_cursor' do
    subject { super().prev_page_cursor }

    it { is_expected.to be_a Cursed::Cursor }

    context 'when cursoring forward' do
      let(:forward) { true }

      its(:after)     { is_expected.to eq nil }
      its(:before)    { is_expected.to eq 2 }
      its(:limit)     { is_expected.to eq 100 }
      its(:maximum)   { is_expected.to eq 100 }
      its(:attribute) { is_expected.to eq :cursor }
      its(:direction) { is_expected.to eq :forward }
    end

    context 'when cursoring backward' do
      let(:forward) { false }

      its(:after)     { is_expected.to eq 6 }
      its(:before)    { is_expected.to eq nil }
      its(:limit)     { is_expected.to eq 100 }
      its(:maximum)   { is_expected.to eq 100 }
      its(:attribute) { is_expected.to eq :cursor }
      its(:direction) { is_expected.to eq :backward }
    end

    context 'while using a non-standard attribute' do
      let(:attribute) { :id }

      its(:attribute) { is_expected.to eq :id }
    end
  end

  describe '#to_a' do
    subject { super().to_a.map(&:id) }

    context 'traversing forward' do
      let(:forward) { true }

      context 'with no before, after or limit' do
        it { is_expected.to eq [1, 7, 3, 4] }

        context 'when using a non-standard attribute' do
          let(:attribute) { :id }

          it { is_expected.to eq [1, 3, 4, 7] }
        end
      end

      context 'when there are more records than limit allows' do
        let(:limit) { 2 }
        it { is_expected.to eq [1, 7] }
      end

      context 'when fetching records after a certan cursor point' do
        let(:after) { 3 } # the cursor value of id=7
        it { is_expected.to eq [3, 4] }

        context 'when using a non-standard attribute' do
          let(:attribute) { :id }
          it { is_expected.to eq [4, 7] }
        end
      end

      context 'when fetching records before a certain cursor point' do
        let(:before) { 5 } # the cursor value of id=3
        it { is_expected.to eq [1, 7] }

        context 'when using a non-standard attribute' do
          let(:attribute) { :id }
          let(:before) { 7 }
          it { is_expected.to eq [1, 3, 4] }
        end
      end
    end

    context 'traversing backward' do
      let(:forward) { false }

      context 'with no before, after or limit' do
        it { is_expected.to eq [4, 3, 7, 1] }

        context 'when using a non-standard attribute' do
          let(:attribute) { :id }

          it { is_expected.to eq [7, 4, 3, 1] }
        end
      end

      context 'when there are more records than limit allows' do
        let(:limit) { 2 }
        it { is_expected.to eq [4, 3] }
      end

      context 'when fetching records after a certan cursor point' do
        let(:after) { 3 } # the cursor value of id=7
        it { is_expected.to eq [4, 3] }

        context 'when using a non-standard attribute' do
          let(:attribute) { :id }
          it { is_expected.to eq [7, 4] }
        end
      end

      context 'when fetching records before a certain cursor point' do
        let(:before) { 5 } # the cursor value of id=3
        it { is_expected.to eq [7, 1] }

        context 'when using a non-standard attribute' do
          let(:attribute) { :id }
          let(:before) { 4 }
          it { is_expected.to eq [3, 1] }
        end
      end
    end
  end
end
