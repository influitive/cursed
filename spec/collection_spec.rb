# frozen_string_literal: true

require 'ostruct'

describe Cursed::Collection do
  subject { collection }

  let(:collection) { described_class.new(relation: relation, cursor: cursor) }

  let(:relation) { DB[:widgets] }

  let(:cursor) do
    OpenStruct.new(
      attribute: attribute,
      forward?: forward,
      backward?: !forward,
      clamped_limit: limit,
      before: before,
      before?: !before.nil?,
      after: after,
      after?: !after.nil?
    )
  end

  let(:attribute) { :cursor }

  let(:forward) { true }

  let(:limit) { 100 }

  let(:after) { nil }

  let(:before) { nil }

  it { is_expected.to be_a(Enumerable) }

  shared_context 'a stubbed relation and adapter' do
    let(:collection) { described_class.new(relation: relation, cursor: cursor, adapter: adapter) }
    let(:adapter) { Cursed::Adapter::Array }
    let(:relation) do
      [
        double(cursor: 5, id: 3),
        double(cursor: 3, id: 7),
        double(cursor: 6, id: 4),
        double(cursor: 2, id: 1)
      ]
    end
  end

  describe '#initialize' do
    it 'works' do
      expect { subject }.not_to raise_error
    end

    its(:relation) { is_expected.to eq relation }
    its(:cursor) { is_expected.to eq cursor }
  end

  describe '#adapter' do
    subject { super().adapter }

    context 'when passing in a Sequel::Dataset' do
      it { is_expected.to eq Cursed::Adapter::Sequel }
    end

    context 'when passing in an ActiveRecord::Base' do
      let(:relation) { Widget.new }
      it { is_expected.to eq Cursed::Adapter::ActiveRecord }
    end

    context 'when passing in an ActiveRecord::Relation' do
      let(:relation) { Widget.unscoped }
      it { is_expected.to eq Cursed::Adapter::ActiveRecord }
    end

    context 'when passing in something unexpected' do
      let(:relation) { double('something unexpected!') }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when providing our own adapter at initialization' do
      include_context 'a stubbed relation and adapter'
      it { is_expected.to eq adapter }
    end
  end

  describe '#maximum_id' do
    subject { super().maximum_id }

    include_context 'a stubbed relation and adapter'

    it { is_expected.to eq 6 }

    context 'when using a non-standard attribute' do
      before { cursor.attribute = :id }

      it { is_expected.to eq 7 }
    end
  end

  describe '#minimum_id' do
    subject { super().minimum_id }

    include_context 'a stubbed relation and adapter'

    it { is_expected.to eq 2 }

    context 'when using a non-standard attribute' do
      before { cursor.attribute = :id }

      it { is_expected.to eq 1 }
    end
  end

  describe '#next_page_params' do
    subject { super().next_page_params }

    include_context 'a stubbed relation and adapter'

    context 'when cursoring forward' do
      let(:forward) { true }

      it { is_expected.to eq(after: 6, limit: 100) }
    end

    context 'when cursoring backward' do
      let(:forward) { false }

      it { is_expected.to eq(before: 2, limit: 100) }
    end
  end

  describe '#prev_page_params' do
    subject { super().prev_page_params }

    include_context 'a stubbed relation and adapter'

    context 'when cursoring forward' do
      let(:forward) { true }

      it { is_expected.to eq(before: 2, limit: 100) }
    end

    context 'when cursoring backward' do
      let(:forward) { false }

      it { is_expected.to eq(after: 6, limit: 100) }
    end
  end

  describe '#to_a' do
    subject { super().to_a.map(&:id) }

    include_context 'a stubbed relation and adapter'

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
