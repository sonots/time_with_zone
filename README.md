# TimeWithZone

Handle Time with Timezone without ActiveSupport or `ENV['TZ']` for thread-safety.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'time_with_zone'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install time_with_zone

## Usage

Assume your local timezone is "Asia/Tokyo", but you want to obtain a time object with timezone "Asia/Taipei":

```ruby
require 'time_with_zone'

Time.strptime("2016-10-20", "%Y-%m-%d")
#=> 2016-10-20 00:00:00 +0900

TimeWithZone.srtptime_with_zone("2016-10-20", "%Y-%m-%d", "Asia/Taipei")
#=> 2016-10-20 00:00:00 +0800
TimeWithZone.srtptime_with_zone("2016-10-20", "%Y-%m-%d", "+08:00")
#=> 2016-10-20 00:00:00 +0800
```

## Limitation

This gem only partially supports short-abbreviation of timezone such as 'PST', 'CST', and 'JST' as ruby iteself only partially supports https://github.com/ruby/ruby/blob/6ce158ba870eb815ba9775ac8380b32fd81be040/lib/time.rb#L97-L113.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/time_with_zone. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

