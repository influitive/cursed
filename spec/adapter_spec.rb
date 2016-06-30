# frozen_string_literal: true

describe Cursed do
  describe '::Adapter' do
    subject { Cursed::Adapter(value) }

    context 'given a sequel dataset' do
      let(:value) { DB[:widgets] }
      it { is_expected.to eq Cursed::Adapter::Sequel }
    end

    context 'given a ActiveRecord::Base' do
      let(:value) { Widget.new }
      it { is_expected.to eq Cursed::Adapter::ActiveRecord }
    end

    context 'given a ActiveRecord::Relation' do
      let(:value) { Widget.unscoped }
      it { is_expected.to eq Cursed::Adapter::ActiveRecord }
    end

    context 'given an adapter object' do
      let(:value) { Cursed::Adapter::Array }
      it { is_expected.to eq Cursed::Adapter::Array }
    end

    context 'given a object which cant be casted' do
      let(:value) { 42 }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end
end
