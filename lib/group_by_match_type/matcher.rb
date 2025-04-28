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

      output_file ||= @input_file.sub(/\.csv$/, '_grouped.csv')

      group_id_map = {}
      next_group_id = 1

      # write grouping column with row data to the output file
      CSV.open(output_file, 'w') do |csv|
        csv << ['group_id'] + rows.headers

        rows.each_with_index do |row, index|
          root = @union_find.find(index.to_s)

          group_id = group_id_map[root] ||= begin
            id = next_group_id
            next_group_id += 1
            id
          end

          csv << [group_id] + row.fields
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
