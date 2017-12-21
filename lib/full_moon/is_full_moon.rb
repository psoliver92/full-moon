require 'active_support/time'

module FullMoon
  class IsFullMoon
    ASTRONOMICAL_EPOCH = 2444238.5.freeze # 1980 January 0.0
    ELONGE = 278.833540.freeze # ecliptic longitude of the Sun at epoch 1980.0
    ELONGP = 282.596403.freeze # ecliptic longitude of the Sun at perigee
    ECCENT = 0.016718.freeze # eccentricity of Earth's orbit
    SUNSMAX =  1.495985e8.freeze # semi-major axis of Earth's orbit, km
    SUNANGSIZ =  0.533128.freeze # sun's angular size, degrees, at semi-major axis distance

    # Elements of the Moon's orbit, epoch 1980.0.
    MMLONG = 64.975464.freeze # moon's mean longitude at the epoch
    MMLONGP =  349.383063.freeze # mean longitude of the perigee at the epoch
    MLNODE = 151.950429.freeze # mean longitude of the node at the epoch
    MINC = 5.145396.freeze # inclination of the Moon's orbit
    MECC = 0.054900.freeze # eccentricity of the Moon's orbit
    MANGSIZ = 0.5181.freeze # moon's angular size at distance a from Earth
    MSMAX =  384401.0.freeze # semi-major axis of Moon's orbit in km
    MPARALLAX = 0.9507.freeze # parallax at distance a from Earth
    SYNMONTH = 29.53058868.freeze # synodic month (new Moon to new Moon)

    def self.is_full_moon(date)
      today = DateTime.parse(date).to_i
      full_moon = false
      phases = phase_list(today)

      phases.each do |phase|
        if phase > 100
          moon_data = get_phase(phase)
          moon_illum = moon_data[1]
          if moon_illum.round == 1
            full_moon = true
            break
          end
        end
      end

      full_moon
    end

    # convert internal date and time to astronomical
    # Julian time (i.e. Julian date plus day fraction)
    def self.julian_time(time)
      (time / 86400.0) + 2440587.5
    end

    # convert Julian day to a UNIX epoch
    def self.julian_day_to_seconds(julian_day)
      (julian_day - 2440587.5) * 86400
    end

    # convert Julian date to DateTime object
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

    # degrees to radians
    def self.to_radian(degrees)
      degrees * Math::PI / 180
    end

    # radians to degrees
    def self.to_degree(radians)
      radians * 180 / Math::PI
    end

    # sin converting degrees to radians
    def self.dsin(angle)
      Math::sin(to_radian(angle))
    end

    # cos converting degrees to radians
    def self.dcos(angle)
      Math::cos(to_radian(angle))
    end

    def self.fix_angle(angle)
      angle - (360.0 * (angle / 360.0).floor)
    end

    def self.kepler(m, ecc)
      epsilon = 1e-6;
      e = m = to_radian(m)

      begin
        delta = e - ecc * Math::sin(e) - m;
        e -= delta / (1 - ecc * Math::cos(e))
      end while delta.abs > epsilon

      e
    end

    def self.get_phase(time)
      pdate = julian_time(time)
      day = pdate - ASTRONOMICAL_EPOCH

      n = fix_angle((360 / 365.2422) * day)
      m = fix_angle(n + ELONGE - ELONGP)
      m_rad = to_radian(m)

      ec = kepler(m, ECCENT)
      ec = Math::sqrt((1 + ECCENT) / (1 - ECCENT)) * Math::tan(ec / 2)
      ec = 2 * to_degree(Math::atan(ec))

      lambda_sun = fix_angle(ec + ELONGP)
      f = (1 + (ECCENT * Math::cos(to_radian(ec)))) / (1 - ECCENT**2)
      sun_dist = SUNSMAX / f
      sun_ang = f * SUNANGSIZ

      ml = fix_angle(13.1763966 * day + MMLONG)

      mm = fix_angle(ml - 0.1114041 * day - MMLONGP)

      mn = fix_angle(MLNODE - 0.0529539 * day)

      ev = 1.2739 * Math::sin(to_radian(2 * (ml - lambda_sun) - mm))

      ae = 0.1858 * Math::sin(m_rad)

      a3 = 0.37 * Math::sin(m_rad)

      mmp = mm + ev - ae - a3

      mec = 6.2886 * Math::sin(to_radian(mmp))

      a4 = 0.214 * Math::sin(to_radian(2 * mmp))

      lp = ml + ev + mec - ae + a4

      v = 0.6583 * Math::sin(to_radian(2 * (lp - lambda_sun)))

      lpp = lp + v

      np = mn - 0.16 * Math::sin(m_rad)

      y = Math::sin(to_radian(lpp - np)) * Math::cos(to_radian(MINC))

      x = Math::cos(to_radian(lpp - np))

      lambda_moon = to_degree(Math::atan2(y, x))
      lambda_moon += np

      beta_m = to_degree(Math::asin(Math::sin(to_radian(lpp - np)) * Math::sin(to_radian(MINC))))

      moon_age = lpp - lambda_sun

      moon_phase = (1 - Math::cos(to_radian(moon_age))) / 2

      moon_dist = (MSMAX * (1 - MECC * MECC)) / (1 + MECC * Math::cos(to_radian(mmp + mec)))

      moon_d_frac = moon_dist / MSMAX
      moon_ang = MANGSIZ / moon_d_frac

      moon_par = MPARALLAX / moon_d_frac
        
      pphase = moon_phase
      mage = SYNMONTH * (fix_angle(moon_age) / 360.0)
      dist = moon_dist
      angdia = moon_ang
      sudist = sun_dist
      suangdia = sun_ang
      mpfrac = fix_angle(moon_age) / 360.0
        
      [mpfrac, pphase, mage, dist, angdia, sudist, suangdia]
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

    def self.phase_list(date)
      start_date = julian_time(date - (3600 * 12))
      end_date = julian_time(date + (3600 * 12))
      phases = []

      date_julian = julian_date(start_date)
      k = ((date_julian.year + ((date_julian.month - 1) * (1/12)) - 1900) * 12.3685).floor - 2

      while 1 do
        k += 1
        defined_phases = [0.0, 0.25, 0.5, 0.75]

        defined_phases.each do |defined_phase|
          d = true_phase(k, defined_phase)
          return phases unless d < end_date

          if d >= start_date
            if phases.empty?
              phases << (4 * defined_phase).floor
            end
            phases << julian_day_to_seconds(d)
          end
        end
      end
    end
  end
end
