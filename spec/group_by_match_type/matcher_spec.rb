# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'
require 'csv'

RSpec.describe GroupByMatchType::Matcher do
  let(:test_csv_rows) do
    <<~CSV
      email,phone,name, Email2, Phone2
      john@example.com,123-456-7890,John Doe,j@example.com, 1234567890
      NO_MATCH@EXAMPLE.COM,987-654-3210,Johnny Doe,JOHN@EXAMPLE.COM,
      jane@example.com,222-222-2222,Jane Smith,, 11234567890
      bob@example.com,555-555-5555,Bob Wilson,
    CSV
  end

  let(:input_file) do
    file = Tempfile.new(['input', '.csv'])
    file.write(test_csv_rows)
    file.close
    file.path
  end

  after do
    File.unlink(input_file) if File.exist?(input_file)
  end

  describe '#process' do
    context 'with same_email matching type' do
      it 'groups records with the same email' do
        matcher = described_class.new(input_file, 'same_email')
        output_file = matcher.process

        rows = CSV.read(output_file, headers: true)
        expect(rows[0]['group_id']).to eq(rows[1]['group_id'])
        expect(rows[0]['group_id']).not_to eq(rows[2]['group_id'])
        expect(rows[0]['group_id']).not_to eq(rows[3]['group_id'])
      end
    end

    context 'with same_phone matching type' do
      it 'groups records with the same phone number' do
        matcher = described_class.new(input_file, 'same_phone')
        output_file = matcher.process

        rows = CSV.read(output_file, headers: true)
        expect(rows[0]['group_id']).to eq(rows[2]['group_id'])
        expect(rows[0]['group_id']).not_to eq(rows[1]['group_id'])
        expect(rows[0]['group_id']).not_to eq(rows[3]['group_id'])
      end
    end

    context 'with same_email_or_phone matching type' do
      it 'groups records with either same email or phone' do
        matcher = described_class.new(input_file, 'same_email_or_phone')
        output_file = matcher.process

        rows = CSV.read(output_file, headers: true)
        expect(rows[0]['group_id']).to eq(rows[1]['group_id'])
        expect(rows[0]['group_id']).to eq(rows[2]['group_id'])
        expect(rows[0]['group_id']).not_to eq(rows[3]['group_id'])
      end
    end

    context 'with invalid matching type' do
      it 'raises an ArgumentError' do
        matcher = described_class.new(input_file, 'invalid_type')
        expect { matcher.process }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#sanitize_phone' do
    let(:klass) { GroupByMatchType::Matcher }

    it 'normalizes US numbers with or without leading 1 to the same value' do
      expect(klass.new(nil, nil).send(:sanitize_phone, '1-800-555-0199')).to eq('8005550199')
      expect(klass.new(nil, nil).send(:sanitize_phone, '800-555-0199')).to eq('8005550199')
    end

    it 'does not remove country codes from non-US numbers' do
      expect(klass.new(nil, nil).send(:sanitize_phone, '121234567890')).to eq('121234567890')
      expect(klass.new(nil, nil).send(:sanitize_phone, '111234567890')).to eq('111234567890')
      expect(klass.new(nil, nil).send(:sanitize_phone, '+44 20 7946 0958')).to eq('442079460958')
    end

    it 'returns only digits for other formats' do
      expect(klass.new(nil, nil).send(:sanitize_phone, '(555) 123-4567')).to eq('5551234567')
      expect(klass.new(nil, nil).send(:sanitize_phone, '555.123.4567')).to eq('5551234567')
    end

    it 'returns nil for nil input' do
      expect(klass.new(nil, nil).send(:sanitize_phone, nil)).to be_nil
    end
  end
end
