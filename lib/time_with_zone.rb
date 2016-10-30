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

  # strptime with timezone
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

  # This method simply overwrites the zone field of Time object
  #
  # <pre>
  # TimeWithZone.overwrite_zone!(Time.parse("2010-02-02 +09:00"), "+08:00")
  # #=> "2010-02-02 00:00:00 +08:00", not "2010-02-01 23:00:00 +08:00"
  # </pre>
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
