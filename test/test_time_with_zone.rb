require_relative 'helper'
require 'time_with_zone'

class TestTimeWithZone < Test::Unit::TestCase
  sub_test_case "zone_offset" do
    def test_zone_offset_with_numeric_pattern
      assert { TimeWithZone.zone_offset("+00:00") == 0 }
      assert { TimeWithZone.zone_offset("+08:00") == 28800 }
      assert { TimeWithZone.zone_offset("-08:00") == -28800 }
    end

    def test_zone_offset_with_name_pattern
      assert { TimeWithZone.zone_offset("UTC") == 0 }
      assert { TimeWithZone.zone_offset("Asia/Taipei") == 28800 }
      assert { TimeWithZone.zone_offset("America/Los_Angeles") == -25200 } # DST
      assert { TimeWithZone.zone_offset("America/Los_Angeles", Time.parse("2016-07-07 +00:00")) == -25200 } # DST
      assert { TimeWithZone.zone_offset("America/Los_Angeles", Time.parse("2016-01-01 +00:00")) == -28800 }
    end

    def test_zone_offset_with_short_abbreviation
      assert { TimeWithZone.zone_offset("UTC") == 0 }
      assert { TimeWithZone.zone_offset("CST") == -21600 } # not China Standard Time in Ruby
      assert { TimeWithZone.zone_offset("PST") == -28800 }
    end
  end

  sub_test_case "overwrite_zone" do
    def test_overwrite_zone
      time = Time.parse("2016-07-07 +00:00") 
      assert { TimeWithZone.overwrite_zone(time, "-08:00").to_s == "2016-07-07 00:00:00 -0800" }
      assert { TimeWithZone.overwrite_zone(time, "PST").to_s == "2016-07-07 00:00:00 -0800" }
      assert { TimeWithZone.overwrite_zone(time, "America/Los_Angeles").to_s == "2016-07-07 00:00:00 -0700" }
    end
  end

  sub_test_case "strptime_with_zone" do
    def test_strptime_with_zone
      time = Time.parse("2016-07-07 +00:00") 
      assert { TimeWithZone.strptime_with_zone("2016-07-07", "%Y-%m-%d", "-08:00").to_s == "2016-07-07 00:00:00 -0800" }
      assert { TimeWithZone.strptime_with_zone("2016-07-07", "%Y-%m-%d", "PST").to_s == "2016-07-07 00:00:00 -0800" }
      assert { TimeWithZone.strptime_with_zone("2016-07-07", "%Y-%m-%d", "America/Los_Angeles").to_s == "2016-07-07 00:00:00 -0700" }
    end
  end

end
