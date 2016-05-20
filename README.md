# StyleInliner
Inline CSS style rules into style attributes of each HTML element.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "style_inliner"
```

And then execute:

```sh
bundle
```

Or install it yourself as:

```sh
gem install style_inliner
```

## Usage

```rb
string = "..."
inliner = StyleInliner::Inliner.new
node = inliner.call(string)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/style_inliner.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
