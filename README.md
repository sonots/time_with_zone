# TimeWithZone

Handle time with zone without ActiveSupport, or `ENV['TZ']` for thread-safety.

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

Assume your localtime zone is `+09:00` (`Asia/Tokyo`):

```ruby
require 'time'

Time.strptime('2015-01-01', '%Y-%m-%d')
#=> 2015-01-01 00:00:00 +0900
```

But, you want to get time in `+08:00` (`Asia/Taipei`) as `2015-01-01 00:00:00 +0800`.

If the timezone format is in numeric formats such as `[+-]HH:MM`, `[+-]HHMM`, `[+-]HH`, you may use `%z` of strptime:

```ruby
require 'time'

date = '2015-01-01'
timezone = '+08:00'
Time.strptime("#{date} #{timezone}", '%Y-%m-%d %z')
#=> 2015-01-01 00:00:00 +0800
```

However, if the timezone format is in the `Region/Zone` format such as `Asia/Taipei`, `%Z` or `%z` won't work. So, use `time_with_zone` gem as:


```ruby
require 'time_with_zone'

TimeWithZone.strptime_with_zone('2015-01-01', '%Y-%m-%d', 'Asia/Taipei')
#=> 2015-01-01 00:00:00 +0800
```

TimeWithZone gem accepts numeric formats, and the `Region/Zone` format, and some of short-abbreviations of timezone such as UTC.

## Documents

Available methods are:

  * strptime_with_zone(str, format, timezone)
  * parse_with_zone(str, timezone)
  * set_zone(time, timezone)
  * zone_offset(timezone, time = nil)
  * strptime_with_zone_offset(str, format, zone_offset)
  * parse_with_zone_offset(str, zone_offset)
  * set_zone_offset(time, zone_offset)

See [docs](https://sonots.github.io/time_with_zone/TimeWithZone.html) for details

## Development

### Run test

```
bundle exec rake
```

### Generate yardoc

```
bundle exec yard
```

### Release

```
bundle exec rake release
```

## CHANGELOG

[CHANGELOG.md](./CHANGELOG.md)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sonots/time_with_zone. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
