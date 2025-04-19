# Group By Match Type

A Ruby gem for identifying and grouping CSV records based on matching email or phone number columns.

## Installation

Install the gem by running:

```bash
gem install group_by_match_type
```

Or add this line to your application's Gemfile:

```ruby
gem 'group_by_match_type'
```

And then execute:

```bash
bundle install
```

## Usage

```bash
group_by_match_type INPUT_FILE MATCHING_TYPE [OUTPUT_FILE]
```

Available matching types:
- `same_email`: Groups records with matching email addresses
- `same_phone`: Groups records with matching phone numbers
- `same_email_or_phone`: Groups records that share either email or phone number

### Examples:
```bash
# Match by email, default output
 group_by_match_type contacts.csv same_email

# Match by phone, default output
 group_by_match_type contacts.csv same_phone

# Match by either email or phone, default output
 group_by_match_type contacts.csv same_email_or_phone

# Specify a custom output file location
 group_by_match_type contacts.csv same_email ~/Downloads/my_grouped_contacts.csv
```

## Output

The gem creates a new CSV file with all the original columns plus a new "group_id" column at the end. Records that are considered to be the same person based on the provided matching_type will have the same group_id. If you specify an `OUTPUT_FILE`, the grouped CSV will be written to that location; otherwise, it will be written as `*_grouped.csv` next to your input file.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).
