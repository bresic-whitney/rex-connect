# frozen_string_literal: true

class Hash
  include BwRex::Core::NavigableHashUtils
end

RSpec.describe BwRex::Core::NavigableHash do
  describe '#dig_and_collect' do
    context 'when key is present' do
      let(:values) { [nil, '', []] }

      context 'when nil' do
        subject { { a: nil } }

        it 'returns the value' do
          expect(subject.dig_and_collect(:a)).to be_nil
        end
      end

      context 'when empty string' do
        subject { { a: '' } }

        it 'returns the value' do
          expect(subject.dig_and_collect(:a)).to eq('')
        end
      end

      context 'when empty array' do
        subject { { a: [] } }

        it 'returns the value' do
          expect(subject.dig_and_collect(:a)).to eq([])
        end
      end
    end

    context 'when no arrays are present' do
      subject do
        {
          a: { b: { c: 'ok' } }
        }
      end

      it 'collects the values' do
        expect(subject.dig_and_collect(:a, :b, :c)).to eq('ok')
      end

      context 'when some key is missing' do
        it 'returns an empty array' do
          expect(subject.dig_and_collect(:a, :zzz, :c)).to be_nil
        end
      end
    end

    context 'when arrays are present' do
      subject do
        {
          a: [
            {
              b: {
                c: [
                  { d: { e: 'ok' } },
                  { d: { e: 'ok' } }
                ]
              }
            },
            {
              b: {
                c: [
                  { d: { e: 'ok' } },
                  { d: { e: 'ok' } }
                ]
              }
            }
          ]
        }
      end

      it 'returns an array with the collected values' do
        expect(subject.dig_and_collect(:a, :b, :c, :d, :e)).to eq(%w[ok ok ok ok])
      end

      context 'when some key in the path is missing' do
        it 'default to empty set' do
          expect(subject.dig_and_collect(:a, :zz, :c, :d, :e)).to be_empty
        end
      end
    end

    context 'when objects are present and we miss the path' do
      subject do
        {
          a: { b: Object.new }
        }
      end

      it 'returns an empty array' do
        expect(subject.dig_and_collect(:a, :b, :c)).to be_nil
      end
    end

    context 'when objects are present and there is a path' do
      subject do
        {
          a: [
            { b: Object.new },
            { b: { c: 'ok' } }
          ]
        }
      end

      it 'returns an empty array' do
        expect(subject.dig_and_collect(:a, :b, :c)).to eq(['ok'])
      end
    end
  end
end
