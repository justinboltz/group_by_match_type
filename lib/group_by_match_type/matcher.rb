# frozen_string_literal: true

require 'csv'
require_relative 'union_find'

module GroupByMatchType
  class Matcher
    def initialize(input_file, match_type)
      @input_file = input_file
      @match_type = match_type
      @union_find = UnionFind.new
    end

    def process(output_file = nil)
      rows = CSV.read(@input_file, headers: true)
      match_keys = build_match_keys(rows)

      # First pass: create groupings
      match_keys.each_with_index do |keys, index|
        @union_find.find_or_create(keys + [index.to_s]) # Ensure uniqueness
      end

      # Second pass: assign group_ids
      group_id_map = {}
      rows.each_with_index do |_, index|
        root = @union_find.find(index.to_s)
        group_id_map[root] ||= group_id_map.size + 1
      end

      # Determine output file path
      output_file ||= @input_file.sub(/\.csv$/, '_grouped.csv')
      CSV.open(output_file, 'w') do |csv|
        csv << rows.headers + ['group_id']
        rows.each_with_index do |row, index|
          root = @union_find.find(index.to_s)
          group_id = group_id_map[root]
          csv << row.fields + [group_id]
        end
      end

      output_file
    end

    private

    def build_match_keys(rows)
      rows.map do |row|
        case @match_type
        when 'same_email'
          emails = extract_emails(row)
          emails.compact.uniq.map(&:downcase).sort
        when 'same_phone'
          phones = extract_phones(row)
          phones.compact.uniq.map { |phone| sanitize_phone(phone) }.compact.sort
        when 'same_email_or_phone'
          (extract_emails(row) + extract_phones(row))
            .compact
            .map { |value| value.include?('@') ? value.downcase : sanitize_phone(value) }
            .compact.uniq.sort
        else
          raise ArgumentError, "Unknown match type: #{@match_type}"
        end
      end
    end

    def extract_emails(row)
      row.headers.grep(/email/i).map { |header| row[header]&.strip }
    end

    def extract_phones(row)
      row.headers.grep(/phone/i).map { |header| row[header]&.strip }
    end

    def sanitize_phone(phone)
      return nil if phone.nil?

      digits = phone.gsub(/\D/, '')
      if digits.length == 11 && digits.start_with?('1')
        digits[1..]
      else
        digits
      end
    end
  end
end
