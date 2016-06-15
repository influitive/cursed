# frozen_string_literal: true

describe Cursed::Cursor do
  subject do
    described_class.new(
      after: after,
      before: before,
      limit: limit,
      maximum: maximum,
      attribute: attribute,
      direction: direction
    )
  end

  let(:after) { 3 }
  let(:before) { 4 }
  let(:limit) { 5 }
  let(:maximum) { 10 }
  let(:attribute) { :id }
  let(:direction) { :forward }

  describe '#initialize' do
    it 'works' do
      expect { subject }.not_to raise_error
    end

    its(:after) { is_expected.to eq 3 }
    its(:before) { is_expected.to eq 4 }
    its(:limit) { is_expected.to eq 5 }
    its(:maximum) { is_expected.to eq 10 }
    its(:attribute) { is_expected.to eq :id }
    its(:direction) { is_expected.to eq :forward }

    context 'when after: is a string' do
      let(:after) { '2' }
      its(:after) { is_expected.to eq 2 }
    end

    context 'when after: is nil' do
      let(:after) { nil }
      its(:after) { is_expected.to eq nil }
    end

    context 'when before: is a string' do
      let(:before) { '3' }
      its(:before) { is_expected.to eq 3 }
    end

    context 'when before: is nil' do
      let(:before) { nil }
      its(:before) { is_expected.to eq nil }
    end

    context 'when limit: is a string' do
      let(:limit) { '5' }
      its(:limit) { is_expected.to eq 5 }
    end

    context 'when maximum: is a string' do
      let(:maximum) { '10' }
      its(:maximum) { is_expected.to eq 10 }
    end

    context 'when direction: is no one of the permitted values' do
      let(:direction) { :sideways }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#clamped_limit' do
    subject { super().clamped_limit }

    context 'when limit is in the range' do
      it { is_expected.to eq 5 }
    end

    context 'when it is < 1' do
      let(:limit) { 0 }
      it { is_expected.to eq 1 }
    end

    context 'when it is > #maximum' do
      let(:limit) { 100 }
      it { is_expected.to eq 10 }
    end
  end

  describe '#forward?' do
    subject { super().forward? }

    context 'when the direction is :forward' do
      let(:direction) { :forward }
      it { is_expected.to eq true }
    end

    context 'when the direction is :backward' do
      let(:direction) { :backward }
      it { is_expected.to eq false }
    end
  end

  describe '#backward?' do
    subject { super().backward? }

    context 'when the direction is :forward' do
      let(:direction) { :forward }
      it { is_expected.to eq false }
    end

    context 'when the direction is :backward' do
      let(:direction) { :backward }
      it { is_expected.to eq true }
    end
  end

  describe '#before?' do
    subject { super().before? }

    context 'when before is non-nil' do
      let(:before) { 10 }
      it { is_expected.to eq true }
    end

    context 'when before is nil' do
      let(:before) { nil }
      it { is_expected.to eq false }
    end
  end

  describe '#after?' do
    subject { super().after? }

    context 'when after is non-nil' do
      let(:after) { 10 }
      it { is_expected.to eq true }
    end

    context 'when after is nil' do
      let(:after) { nil }
      it { is_expected.to eq false }
    end
  end
end
