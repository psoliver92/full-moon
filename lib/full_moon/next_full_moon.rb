module FullMoon
  class NextFullMoon
    SYNMONTH = 29.53058868.freeze

    def self.next_full_moon
      time = Time.now.to_i
      full_moon = moon_phase(time, 0.5)

      return moon_phase(time, 0.5, true).floor if full_moon < time

      full_moon.floor
    end

    def self.next_full_moon_from(future_time)
      time = future_time.to_i
      full_moon = moon_phase(time, 0.5)

      return moon_phase(time, 0.5, true).floor if full_moon < time

      full_moon.floor
    end

    def self.moon_phase(time, phase, second=false)
      k1k2 = time_2k_1_k2(time)

      return julian_day_to_seconds(true_phase(k1k2[0], phase)) unless second

      julian_day_to_seconds(true_phase(k1k2[1], phase))
    end

    def self.time_2k_1_k2(time)
      start_date = julian_time(time)
      a_date = start_date - 45

      date_julian = julian_date(a_date)
      k1 = ((date_julian.year + ((date_julian.month - 1) * (1.0 / 12.0)) - 1900) * 12.3685 ).floor
      # why using a_date again
      a_date = nt1 = mean_phase(a_date, k1)

      while 1 do
        a_date += SYNMONTH
        k2 = k1 + 1
        nt2 = mean_phase(a_date, k2)
        if nt1 <= a_date &&nt2 > start_date
          break
        end
        nt1 = nt2
        k1 = k2
      end

      [k1, k2]
    end

    def self.julian_time(time)
      (time / 86400.0) + 2440587.5
    end

    def self.julian_date(td)
      td += 0.5
      z = td.floor
      f = td - z
      if z < 2299161.0
        a = z
      else
        alpha = ((z - 1867216.25) / 36524.25).floor
        a = z + 1 + alpha - (alpha / 4).floor
      end

      b = a + 1524
      c = ((b - 122.1) / 365.25).floor
      d = (365.25 * c).floor
      e = ((b - d) / 30.6001).floor

      dd = b - d - (30.6001 * e).floor + f
      mm = e < 14 ? e - 1 : e - 13
      yy = mm > 2 ? c - 4716 : c - 4715

      DateTime.parse("#{yy}-#{mm}-#{dd}")
    end


    # Calculates time of the mean new Moon for a given
    # base date. This argument K to this function is the
    # precomputed synodic month index, given by:
    # K = (year - 1900) * 12.3685
    # where year is expressed as a year and fractional year.
    def self.mean_phase(start_date, k)
      t = (start_date - 2415020) / 365.25 # time in centuries since 1900 January 0.5
      t2 = t**2

      nt1 = 2415020.75933 + SYNMONTH * k
        + 0.0001178 * t2
        - 0.000000155 * t**3
        + 0.00033 * dsin( 166.56 + 132.87 * t - 0.009173 * t2 )

      nt1
    end

    def self.dsin(angle)
      Math::sin(to_radian(angle))
    end

    def self.to_radian(degrees)
      degrees * Math::PI / 180
    end

    def self.true_phase(k, phase)
      apcor = 0
      k += phase
      t = k / 1236.85
      t2 = t**2
      t3 = t**3

      pt = 2415020.75933 + (SYNMONTH * k) + (0.0001178 * t2) - (0.000000155 * t3) + (0.00033 * dsin(166.56 + 132.87 * t - 0.009173 * t2))

      m = 359.2242 + (29.10535608 * k) - (0.0000333 * t2) - (0.00000347 * t3)

      mprime = 306.0253 + (385.81691806 * k) + (0.0107306 * t2) + (0.00001236 * t3)

      f = 21.2964 + (390.67050646 * k) - (0.0016528 * t2) - (0.00000239 * t3)

      if phase < 0.01 || (phase - 0.5).abs < 0.01
        pt += (0.1734 - 0.000393 * t) * dsin(m)
          + (0.0021 * dsin(2 * m ))
          - (0.4068 * dsin(mprime))
          + (0.0161 * dsin(2 * mprime))
          - (0.0004 * dsin(3 * mprime))
          + (0.0104 * dsin(2 * f))
          - (0.0051 * dsin(m + mprime))
          - (0.0074 * dsin(m - mprime))
          + (0.0004 * dsin(2 * f + m))
          - (0.0004 * dsin(2 * f - m))
          - (0.0006 * dsin(2 * f + mprime))
          + (0.0010 * dsin(2 * f - mprime))
          + (0.0005 * dsin(m + 2 * mprime))

        apcor = 1
      elsif (phase - 0.25).abs < 0.01 || (phase - 0.75).abs < 0.01
        pt += (0.1721 - 0.0004 * t) * dsin(m)
        + 0.0021 * dsin(2 * m)
        - 0.6280 * dsin(mprime)
        + 0.0089 * dsin(2 * mprime)
        - 0.0004 * dsin(3 * mprime)
        + 0.0079 * dsin(2 * f)
        - 0.0119 * dsin(m + mprime)
        - 0.0047 * dsin(m - mprime)
        + 0.0003 * dsin(2 * f + m)
        - 0.0004 * dsin(2 * f - m)
        - 0.0006 * dsin(2 * f + mprime)
        + 0.0021 * dsin(2 * f - mprime)
        + 0.0003 * dsin(m + 2 * mprime)
        + 0.0004 * dsin(m - 2 * mprime)
        - 0.0003 * dsin(2 * m + mprime)

        if phase < 0.5
          pt += 0.0028 - 0.0004 * dcos(m) + 0.0003 * dcos(mprime)
        else
          pt += -0.0028 + 0.0004 * dcos(m) - 0.0003 * dcos(mprime)
        end

        apcor = 1
      end

      pt
    end

    def self.julian_day_to_seconds(julian_day)
      (julian_day - 2440587.5) * 86400
    end
  end
end
