require_relative 'time_with_zone/version'
require 'time'
require 'tzinfo'

class TimeWithZone
  # [+-]HH:MM, [+-]HHMM, [+-]HH
  NUMERIC_PATTERN = %r{\A[+-]\d\d(:?\d\d)?\z}

  # Region/Zone, Region/Zone/Zone
  NAME_PATTERN = %r{\A[^/]+/[^/]+(/[^/]+)?\z}

  # Short-abbreviation timezone which Ruby's Time class supports
  ZoneOffset = (class << Time; self; end)::ZoneOffset

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
    overwrite_zone!(time, timezone)
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
    overwrite_zone!(time, timezone)
  end

  # This method simply overwrites the zone field of Time object
  #
  # @see overwrite_zone!
  def self.overwrite_zone(time, timezone)
    overwrite_zone!(time.dup, timezone)
  end

  # This method simply overwrites the zone field of Time object destructively
  #
  #     require 'time_with_zone'
  #
  #     TimeWithZone.overwrite_zone!(Time.parse("2010-02-02 +09:00"), "+08:00")
  #     #=> "2010-02-02 00:00:00 +08:00" (Note that not "2010-02-01 23:00:00 +08:00")
  #
  # @param [Time] time
  # @param [String] timezone
  # @return [Time]
  def self.overwrite_zone!(time, timezone)
    _utc_offset = time.utc_offset
    _zone_offset = zone_offset(timezone, time)
    time.localtime(_zone_offset) + _utc_offset - _zone_offset
  end

  # Returns zone offset for given timezone string
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
