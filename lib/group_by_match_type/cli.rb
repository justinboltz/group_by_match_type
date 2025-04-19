# frozen_string_literal: true

require 'optparse'
require_relative 'matcher'

module GroupByMatchType
  class CLI
    VALID_TYPES = %w[same_email same_phone same_email_or_phone].freeze

    def self.start(args)
      if args.empty? || args.include?('-h') || args.include?('--help')
        show_help
        exit(args.empty? ? 1 : 0)
      end

      if args.length < 2 || args.length > 3
        puts 'Error: Please provide the input file, matching type, and optionally an output file path'
        show_help
        exit 1
      end

      input_file, matching_type, output_file = args

      unless VALID_TYPES.include?(matching_type)
        puts "Error: Invalid matching type '#{matching_type}'"
        show_help
        exit 1
      end

      unless File.exist?(input_file)
        puts "Error: File '#{input_file}' does not exist"
        exit 1
      end

      begin
        matcher = Matcher.new(input_file, matching_type)
        output = matcher.process(output_file)
        puts "Processing complete. Output written to: #{output}"
      rescue StandardError => e
        puts "Error: #{e.message}"
        exit 1
      end
    end

    def self.show_help
      puts <<~HELP_MESSAGE
        Usage: group_by_match_type INPUT_FILE MATCHING_TYPE [OUTPUT_FILE]

        Arguments:
          INPUT_FILE    Path to the CSV file to process
          MATCHING_TYPE One of: same_email, same_phone, same_email_or_phone
          OUTPUT_FILE   (Optional) Path to save the grouped CSV output

        Example:
          group_by_match_type contacts.csv same_email ~/Downloads/contacts_grouped.csv
      HELP_MESSAGE
    end
  end
end
