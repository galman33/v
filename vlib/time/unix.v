// Copyright (c) 2019-2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module time

// unix returns a time struct from Unix time.
pub fn unix(abs int) Time {
	return Time{i64(abs) * microseconds_per_second}
}

// unix2 returns a time struct from Unix time and microsecond value
pub fn unix2(abs int, microsecond int) Time {
	return Time {i64(abs) * microseconds_per_second + microsecond}
}

fn abs_seconds_to_date(abs_seconds u64) (int, int, int) {
	// Split into time and day.
	mut d := abs_seconds / seconds_per_day

	// Account for 400 year cycles.
	mut n := d / days_per_400_years
	mut y := 400 * n
	d -= days_per_400_years * n

	// Cut off 100-year cycles.
	// The last cycle has one extra leap year, so on the last day
	// of that year, day / daysPer100Years will be 4 instead of 3.
	// Cut it back down to 3 by subtracting n>>2.
	n = d / days_per_100_years
	n -= n >> 2
	y += 100 * n
	d -= days_per_100_years * n

	// Cut off 4-year cycles.
	// The last cycle has a missing leap year, which does not
	// affect the computation.
	n = d / days_per_4_years
	y += 4 * n
	d -= days_per_4_years * n

	// Cut off years within a 4-year cycle.
	// The last year is a leap year, so on the last day of that year,
	// day / 365 will be 4 instead of 3. Cut it back down to 3
	// by subtracting n>>2.
	n = d / 365
	n -= n >> 2
	y += n
	d -= 365 * n

	year := int(i64(y) + absolute_zero_year)
	yday := int(d)

	mut day := yday
	if is_leap_year(year) {
		// Leap year
		if day > 31+29-1 {
			// After leap day; pretend it wasn't there.
			day--
		} else if day == 31+29-1 {
			// Leap day.
			return year, 2, 29
		}
	}

	// Estimate month on assumption that every month has 31 days.
	// The estimate may be too low by at most one month, so adjust.
	mut month := day / 31
	end := int(days_before[month+1])
	mut begin := 0
	if day >= end {
		month++
		begin = end
	} else {
		begin = int(days_before[month])
	}

	month++ // because January is 1
	day = day - begin + 1
	return year, month, day
}