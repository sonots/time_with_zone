require_relative 'time_with_zone/version'
require 'time'
require 'tzinfo'

# Handle time with zone withtout ActiveSupport or ENV\['TZ'\]
#
#     require 'time_with_zone'
#
#     TimeWithZone.strptime_with_zone('2016-10-10', '%Y-%m-%d', 'Asia/Taipei')
#     # => '2016-10-10 00:00:00 +0800'
#
#     TimeWithZone.parse_with_zone('2016-10-10', 'Asia/Taipei')
#     # => '2016-10-10 00:00:00 +0800'
#
#     time = Time.parse('2016-10-10 00:00:00 +00:00')
#     TimeWithZone.set_zone!(time, 'Asia/Taipei')
#     # => '2016-10-10 00:00:00 +0800'
#
#     time = Time.parse('2016-10-10 00:00:00 +00:00')
#     TimeWithZone.localtime_with_zone(time, 'Asia/Taipei')
#     # => '2016-10-10 08:00:00 +0800'
class TimeWithZone
  # [+-]HH:MM, [+-]HHMM, [+-]HH
  NUMERIC_PATTERN = %r{\A[+-]\d\d(:?\d\d)?\z}

  # Region/Zone, Region/Zone/Zone
  NAME_PATTERN = %r{\A[^/]+/[^/]+(/[^/]+)?\z}

  # Short-abbreviation timezone which Ruby's Time class supports
  #
  # @see https://github.com/ruby/ruby/blob/6ce158ba870eb815ba9775ac8380b32fd81be040/lib/time.rb#L97-L113
  ZoneOffset = (class << Time; self; end)::ZoneOffset

  # Time#localtime with timezone (non-destructive)
  #
  #      ENV['TZ'] = '+09:00' # Assume your local timezone is +09:00
  #
  #      require 'time'
  #
  #      time = Time.parse("2016-10-20 00:00:00 +00:00") 
  #      time.dup.localtime("+08:00")
  #      #=> 2010-10-20 08:00:00 +0800
  #      time.dup.localtime("CDT")
  #      #=> error
  #      time.dup.localtime("Asia/Taipei")
  #      #=> error
  #
  #      require 'time_with_zone'
  #
  #      time = Time.parse("2016-10-20 00:00:00 +00:00") 
  #      TimeWithZone.localtime_with_zone(time, "+08:00")
  #      #=> 2010-10-20 08:00:00 +0800
  #      TimeWithZone.localtime_with_zone(time, "CDT")
  #      #=> 2016-10-19 19:00:00 -0500
  #      TimeWithZone.localtime_with_zone(time, "Asia/Taipei")
  #      #=> 2010-10-20 08:00:00 +0800
  #
  # This method is actually a short-hand of
  #
  #      require 'time_with_zone'
  #      time = Time.parse("2016-10-20 00:00:00 +00:00")
  #
  #      time.dup.localtime(TimeWithZone.zone_offset("Asia/Taipei"))
  #      #=> 2010-10-20 08:00:00 +0800
  #
  # @param [Time] time object
  # @param [String] timezone {NUMERIC_PATTERN} or {NAME_PATTERN} or {ZoneOffset}
  # @param [Time]
  def self.localtime_with_zone(time, timezone)
    localtime_with_zone!(time.dup, timezone)
  end

  # Time#localtime with timezone (destructive)
  #
  # @param [Time] time object
  # @param [String] timezone {NUMERIC_PATTERN} or {NAME_PATTERN} or {ZoneOffset}
  # @see localtime_with_zone
  def self.localtime_with_zone!(time, timezone)
    _zone_offset = zone_offset(timezone, time)
    time.localtime(_zone_offset)
  end

  # Time.parse with timezone
  #
  #      ENV['TZ'] = '+09:00' # Assume your local timezone is +09:00
  #
  #      require 'time'
  #
  #      Time.parse("2016-10-20")
  #      #=> 2016-10-20 00:00:00 +0900
  #      Time.parse("2016-10-20 00:00:00 +08:00")
  #      #=> 2016-10-20 00:00:00 +0800
  #      Time.parse("2016-10-20 00:00:00 CDT")
  #      #=> 2016-10-20 00:00:00 -0500
  #      Time.parse("2016-10-20 00:00:00 Asia/Taipei")
  #      #=> 2016-10-20 00:00:00 +0900 (does not work)
  #
  #      require 'time_with_zone'
  #
  #      TimeWithZone.parse_with_zone("2016-10-20", "+08:00")
  #      #=> 2016-10-20 00:00:00 +0800
  #      TimeWithZone.parse_with_zone("2016-10-20", "CDT")
  #      #=> 2016-10-20 00:00:00 -0500
  #      TimeWithZone.parse_with_zone("2016-10-20", "Asia/Taipei")
  #      #=> 2016-10-20 00:00:00 +0800
  #
  # @param [String] date string to be parsed
  # @param [String] timezone {NUMERIC_PATTERN} or {NAME_PATTERN} or {ZoneOffset}
  def self.parse_with_zone(date, timezone)
    time = Time.parse(date)
    set_zone!(time, timezone)
  end

  # Time.strptime with timezone
  #
  #      ENV['TZ'] = '+09:00' # Assume your local timezone is +09:00
  #
  #      require 'time'
  #
  #      Time.strptime("2016-10-20", "%Y-%m-%d")
  #      #=> 2016-10-20 00:00:00 +0900
  #      Time.strptime("2016-10-20 +08:00", "%Y-%m-%d %z")
  #      #=> 2016-10-20 00:00:00 +0800
  #      Time.strptime("2016-10-20 CDT", "%Y-%m-%d %Z")
  #      #=> 2016-10-20 00:00:00 -0500
  #      Time.strptime("2016-10-20 Asia/Taipei", "%Y-%m-%d %Z")
  #      #=> 2016-10-20 00:00:00 +0900 (does not work)
  #
  #      require 'time_with_zone'
  #
  #      TimeWithZone.strptime_with_zone("2016-10-20", "%Y-%m-%d", "+08:00")
  #      #=> 2016-10-20 00:00:00 +0800
  #      TimeWithZone.strptime_with_zone("2016-10-20", "%Y-%m-%d", "CDT")
  #      #=> 2016-10-20 00:00:00 -0500
  #      TimeWithZone.strptime_with_zone("2016-10-20", "%Y-%m-%d", "Asia/Taipei")
  #      #=> 2016-10-20 00:00:00 +0800
  #
  # @param [String] date string to be parsed
  # @param [String] format
  # @param [String] timezone {NUMERIC_PATTERN} or {NAME_PATTERN} or {ZoneOffset}
  def self.strptime_with_zone(date, format, timezone)
    time = Time.strptime(date, format)
    set_zone!(time, timezone)
  end

  # This method simply sets the zone field of Time object (non-destructive)
  #
  #     require 'time_with_zone'
  #
  #     time = Time.parse("2016-02-02 00:00:00 +00:00")
  #     TimeWithZone.set_zone(time, "+08:00")
  #     #=> "2016-02-02 00:00:00 +0800"
  #     # Note that it is not "2016-02-02 08:00:00 +0800" like Time#localtime(timezone)
  #
  # @param [Time] time
  # @param [String] timezone
  # @return [Time]
  def self.set_zone(time, timezone)
    set_zone!(time.dup, timezone)
  end

  # This method simply sets the zone field of Time object (destructive)
  #
  # @param [Time] time
  # @param [String] timezone
  # @see set_zone
  def self.set_zone!(time, timezone)
    set_zone_offset!(time, zone_offset(timezone, time))
  end

  # This method simply sets the zone offset field of Time object (non-destructive)
  #
  #     require 'time_with_zone'
  #     time = Time.parse("2016-02-02 00:00:00 +00:00")
  #
  #     TimeWithZone.set_zone_offset(time, 28800)
  #     #=> "2016-02-02 00:00:00 +0800"
  #     # Note that it is not "2016-02-02 08:00:00 +0800" like Time#localtime(zone_offset)
  #
  # @param [Time] time
  # @param [Integer] zone_offset
  # @return [Time]
  def self.set_zone_offset(time, zone_offset)
    set_zone_offset!(time.dup, zone_offset)
  end

  # This method simply sets the zone offset field of Time object (destructive)
  #
  # @param [Time] time
  # @param [Integer] zone_offset
  # @see set_zone_offset
  def self.set_zone_offset!(time, zone_offset)
    utc_offset = time.utc_offset
    time.localtime(zone_offset) + utc_offset - zone_offset
  end

  # Returns zone offset for given timezone string
  #
  #     require 'time_with_zone'
  #
  #     TimeWithZone.zone_offset("+08:00")
  #     #=> 28800
  #     TimeWithZone.zone_offset("Asia/Taipei")
  #     #=> 28800
  #     TimeWithZone.zone_offset("PST")
  #     #=> -28800
  #     TimeWithZone.zone_offset("America/Los_Angeles")
  #     #=> -25200 
  #     TimeWithZone.zone_offset("America/Los_Angeles", Time.parse("2016-07-07 00:00:00 +00:00"))
  #     #=> -25200 # DST (Daylight Saving Time)
  #     TimeWithZone.zone_offset("America/Los_Angeles", Time.parse("2016-01-01 00:00:00 +00:00"))
  #     #=> -28800 # non DST
  #
  # @param [String] timezone {NUMERIC_PATTERN} or {NAME_PATTERN} or {ZoneOffset}
  # @param [Time] time if you need to consider Daylight Saving Time
  # @return [Integer] zone offset
  def self.zone_offset(timezone, time = nil)
    if NUMERIC_PATTERN === timezone
      Time.zone_offset(timezone)
    elsif NAME_PATTERN === timezone
      tz = TZInfo::Timezone.get(timezone)
      if time
        tz.period_for_utc(time).utc_total_offset
      else
        tz.current_period.utc_total_offset
      end
    elsif ZoneOffset.include?(timezone)
      ZoneOffset[timezone] * 3600
    else
      raise ArgumentError, "timezone format is invalid: #{timezone}"
    end
  end
end
