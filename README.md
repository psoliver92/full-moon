# FullMoon

This gem is a ruby translation and implementation of the [Astro::MoonPhase Perl module](http://search.cpan.org/~brett/Astro-MoonPhase-0.60/MoonPhase.pm). You can use this gem to determine the occurrence of the next full moon or to determine if a given date is/was/will be a full moon.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'full_moon'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install full_moon

## Usage

Two classes can be called. One determines the next full moon. The other determines if a given date is a full moon or not.

```
FullMoon::NextFullMoon.next_full_moon
# returns EPOCH for next full moon

FullMoon::IsFullMoon.is_full_moon('2018-01-02')
# returns true or false
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/full_moon. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the FullMoon project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/full_moon/blob/master/CODE_OF_CONDUCT.md).
