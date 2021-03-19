// Copyright (c) 2019-2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module time

pub const (
	days_string        = 'MonTueWedThuFriSatSun'
	month_days         = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	months_string      = 'JanFebMarAprMayJunJulAugSepOctNovDec'
	// The unsigned zero year for internal calculations.
	// Must be 1 mod 400, and times before it will not compute correctly,
	// but otherwise can be changed at will.
	absolute_zero_year = i64(-292277022399) // as i64
	// The year of the zero Time.
	// Assumed by the unix_to_internal computation below.
	internal_year = 1
	// Offsets to convert between internal and absolute or Unix times.
	absolute_to_internal = i64(absolute_zero_year - internal_year) * i64(365.2425 * f64(seconds_per_day))
	internal_to_absolute       = -absolute_to_internal
	unix_to_internal = i64(1969*365 + 1969/4 - 1969/100 + 1969/400) * seconds_per_day
	internal_to_unix = -unix_to_internal
	/*microseconds_per_millisecond = i64(1000)
	microseconds_per_second = i64(1000) * microseconds_per_millisecond
	microseconds_per_minute = i64(160) * microseconds_per_second
	microseconds_per_hour   = i64(160) * microseconds_per_minute
	microseconds_per_day    = i64(124) * microseconds_per_hour
	microseconds_per_week   = i64(17) * microseconds_per_day*/
	microseconds_per_millisecond = i64(1000)
	microseconds_per_second = i64(1000) * i64(1000)
	microseconds_per_minute = i64(1000) * i64(1000) * i64(60)
	microseconds_per_hour   = i64(1000) * i64(1000) * i64(60) * i64(60)
	microseconds_per_day    = i64(1000) * i64(1000) * i64(60) * i64(60) * i64(24)
	microseconds_per_week   = i64(1000) * i64(1000) * i64(60) * i64(60) * i64(24) * i64(7)

	seconds_per_minute = 60
	seconds_per_hour   = 60 * 60
	seconds_per_day    = 60 * 60 * 24
	
	days_per_400_years = 365 * 400 + 97
	days_per_100_years = 365 * 100 + 24
	days_per_4_years   = 365 * 4 + 1
	days_before        = [
		0,
		31,
		31 + 28,
		31 + 28 + 31,
		31 + 28 + 31 + 30,
		31 + 28 + 31 + 30 + 31,
		31 + 28 + 31 + 30 + 31 + 30,
		31 + 28 + 31 + 30 + 31 + 30 + 31,
		31 + 28 + 31 + 30 + 31 + 30 + 31 + 31,
		31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 + 30,
		31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 + 30 + 31,
		31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 + 30 + 31 + 30,
		31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 + 30 + 31 + 30 + 31,
	]
	long_days          = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
)

// Time contains various time units for a point in time.
pub struct Time {
	unix_microseconds	i64
}

pub struct Date {
pub:
	year        int
	month       int
	day         int
	hour        int
	minute      int
	second      int
	microsecond int
}

// FormatDelimiter contains different time formats.
pub enum FormatTime {
	hhmm12
	hhmm24
	hhmmss12
	hhmmss24
	hhmmss24_milli
	hhmmss24_micro
	no_time
}

// FormatDelimiter contains different date formats.
pub enum FormatDate {
	ddmmyy
	ddmmyyyy
	mmddyy
	mmddyyyy
	mmmd
	mmmdd
	mmmddyyyy
	no_date
	yyyymmdd
}

// FormatDelimiter contains different time/date delimiters.
pub enum FormatDelimiter {
	dot
	hyphen
	slash
	space
	no_delimiter
}

// now returns current local time.
pub fn now() Time {
	return Time{os_unix_time_microseconds() + offset() * microseconds_per_second}
}

// utc returns the current UTC time.
pub fn utc() Time {
	return Time{os_unix_time_microseconds()}
}

pub fn (t Time) year() int {
	year, _, _ := abs_seconds_to_date(t.abs_seconds())
	return year
}

pub fn (t Time) month() int {
	_, month, _ := abs_seconds_to_date(t.abs_seconds())
	return month
}

pub fn (t Time) day() int {
	_, _, day := abs_seconds_to_date(t.abs_seconds())
	return day
}

pub fn (t Time) date() Date {
	year, month, day := abs_seconds_to_date(t.abs_seconds())
	return Date{
		year: year
		month: month
		day: day
		hour: t.hour()
		minute: t.minute()
		second: t.second()
		microsecond: t.microsecond()
	}
}

fn calc_time(microseconds i64, high i64, low i64, mod int) int {
	result := int(microseconds % high / low)
	if result < 0 {
		return result + mod
	} else {
		return result
	}
}

pub fn (t Time) hour() int {
	return int(t.abs_seconds() % seconds_per_day) / seconds_per_hour
}

pub fn (t Time) minute() int {
	return int(t.abs_seconds() % seconds_per_hour) / seconds_per_minute
}

pub fn (t Time) second() int {
	return int(t.abs_seconds() % seconds_per_minute)
}

pub fn (t Time) microsecond() int {
	result := int(t.unix_microseconds % microseconds_per_second)
	if result < 0 {
		return result + int(microseconds_per_second)
	} else {
		return result
	}
}

fn (t Time) abs_seconds() u64 {
	return u64(t.unix() + (unix_to_internal + internal_to_absolute))
}

// smonth returns month name.
pub fn (t Time) smonth() string {
	month := t.month()
	if month <= 0 || month > 12 {
		return '---'
	}
	i := month - 1
	return time.months_string[i * 3..(i + 1) * 3]
}

// new_time returns a time struct with calculated Unix time.
pub fn new_time(date Date) Time {
	mut year, mut month, mut day, mut h, mut min, mut sec, mut msec := date.year, date.month, date.day, date.hour, date.minute, date.second, date.microsecond

	// Normalize month, overflowing into year.
	mut m := month - 1
	year, m = norm(year, m, 12)
	month = m + 1

	// Normalize nsec, sec, min, hour, overflowing into day.
	sec, msec = norm(sec, msec, 1000000)
	min, sec = norm(min, sec, 60)
	h, min = norm(h, min, 60)
	day, h = norm(day, h, 24)

	// Compute days since the absolute epoch.
	mut d := days_since_epoch(year)

	// Add in days before this month.
	d += days_before[month-1]
	if is_leap_year(year) && month >= 3 {
		d++ // February 29
	}

	// Add in days before today.
	d += day - 1

	// Add in time elapsed today.
	mut abs_microseconds := d * microseconds_per_day +
		h * microseconds_per_hour + 
		min * microseconds_per_minute +
		sec * microseconds_per_second +
		msec

	unix_microseconds := abs_microseconds + (absolute_to_internal + internal_to_unix) * microseconds_per_second

	return Time{unix_microseconds}
}

// norm returns nhi, nlo such that
//	hi * base + lo == nhi * base + nlo
//	0 <= nlo < base
fn norm(hi int, lo int, base int) (int, int) {
	mut out_hi, mut out_lo := hi, lo
	if out_lo < 0 {
		n := (-out_lo-1)/base + 1
		out_hi -= n
		out_lo += n * base
	}
	if out_lo >= base {
		n := out_lo / base
		out_hi += n
		out_lo -= n * base
	}
	return out_hi, out_lo
}


// daysSinceEpoch takes a year and returns the number of days from
// the absolute epoch to the start of that year.
// This is basically (year - zeroYear) * 365, but accounting for leap days.
fn days_since_epoch(year int) i64 {
	mut y := i64(year) - absolute_zero_year

	// Add in days from 400-year cycles.
	mut n := y / 400
	y -= 400 * n
	mut d := days_per_400_years * n

	// Add in 100-year cycles.
	n = y / 100
	y -= 100 * n
	d += days_per_100_years * n

	// Add in 4-year cycles.
	n = y / 4
	y -= 4 * n
	d += days_per_4_years * n

	// Add in non-leap years.
	n = y
	d += 365 * n

	return d
}

// unix returns Unix time.
[inline]
pub fn (t Time) unix() int {
	return int(t.unix_microseconds / microseconds_per_second)
}

// unix_milli returns Unix time with millisecond resolution.
[inline]
pub fn (t Time) unix_milli() i64 {
	return t.unix_microseconds / microseconds_per_millisecond
}

// unix_micro returns Unix time with microsecond resolution.
[inline]
pub fn (t Time) unix_micro() i64 {
	return t.unix_microseconds
}

// add returns a new time that duration is added
pub fn (t Time) add(d Duration) Time {
	unix_microseconds := t.unix_microseconds + d.microseconds()
	return Time{unix_microseconds}
}

// add_seconds returns a new time struct with an added number of seconds.
pub fn (t Time) add_seconds(seconds int) Time {
	return t.add(seconds * time.second)
}

// add_days returns a new time struct with an added number of days.
pub fn (t Time) add_days(days int) Time {
	return t.add(days * 24 * time.hour)
}

// since returns a number of seconds elapsed since a given time.
fn since(t Time) int {
	// TODO Use time.Duration instead of seconds
	return 0
}

// relative returns a string representation of the difference between t
// and the current time.
pub fn (t Time) relative() string {
	znow := now()
	secs := (znow.unix_microseconds - t.unix_microseconds) / microseconds_per_second
	if secs <= 30 {
		// right now or in the future
		// TODO handle time in the future
		return 'now'
	}
	if secs < 60 {
		return '1m'
	}
	if secs < 3600 {
		m := secs / 60
		if m == 1 {
			return '1 minute ago'
		}
		return '$m minutes ago'
	}
	if secs < 3600 * 24 {
		h := secs / 3600
		if h == 1 {
			return '1 hour ago'
		}
		return '$h hours ago'
	}
	if secs < 3600 * 24 * 5 {
		d := secs / 3600 / 24
		if d == 1 {
			return '1 day ago'
		}
		return '$d days ago'
	}
	if secs > 3600 * 24 * 10000 {
		return ''
	}
	return t.md()
}

// relative_short returns a string saying how long ago a time occured as follows:
// 0-30 seconds: `"now"`; 30-60 seconds: `"1m"`; anything else is rounded to the
// nearest minute, hour or day; anything higher than 10000 days (about 27 years)
// years returns an empty string.
// Some Examples:
// `0s -> 'now'`;
// `20s -> 'now'`;
// `47s -> '1m'`;
// `456s -> '7m'`;
// `1234s -> '20m'`;
// `16834s -> '4h'`;
// `1687440s -> '33d'`;
// `15842354871s -> ''`
pub fn (t Time) relative_short() string {
	znow := now()
	secs := (znow.unix_microseconds - t.unix_microseconds) / microseconds_per_second
	if secs <= 30 {
		// right now or in the future
		// TODO handle time in the future
		return 'now'
	}
	if secs < 60 {
		return '1m'
	}
	if secs < 3600 {
		return '${secs / 60}m'
	}
	if secs < 3600 * 24 {
		return '${secs / 3600}h'
	}
	if secs < 3600 * 24 * 5 {
		return '${secs / 3600 / 24}d'
	}
	if secs > 3600 * 24 * 10000 {
		return ''
	}
	return t.md()
}

// day_of_week returns the current day of a given year, month, and day,
// as an integer.
pub fn day_of_week(y int, m int, d int) int {
	// Sakomotho's algorithm is explained here:
	// https://stackoverflow.com/a/6385934
	t := [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4]
	mut sy := y
	if m < 3 {
		sy = sy - 1
	}
	return (sy + sy / 4 - sy / 100 + sy / 400 + t[m - 1] + d - 1) % 7 + 1
}

// day_of_week returns the current day as an integer.
pub fn (t Time) day_of_week() int {
	return day_of_week(t.year(), t.month(), t.day())
}

// weekday_str returns the current day as a string.
pub fn (t Time) weekday_str() string {
	i := t.day_of_week() - 1
	return time.days_string[i * 3..(i + 1) * 3]
}

// weekday_str returns the current day as a string.
pub fn (t Time) long_weekday_str() string {
	i := t.day_of_week() - 1
	return time.long_days[i]
}

// ticks returns a number of milliseconds elapsed since system start.
pub fn ticks() i64 {
	$if windows {
		return C.GetTickCount()
	} $else {
		ts := C.timeval{}
		C.gettimeofday(&ts, 0)
		return i64(ts.tv_sec * u64(1000) + (ts.tv_usec / u64(1000)))
	}
	// t := i64(C.mach_absolute_time())
	// # Nanoseconds elapsedNano = AbsoluteToNanoseconds( *(AbsoluteTime *) &t );
	// # return (double)(* (uint64_t *) &elapsedNano) / 1000000;
}

/*
// sleep makes the calling thread sleep for a given number of seconds.
[deprecated: 'call time.sleep(n * time.second)']
pub fn sleep(seconds int) {
	wait(seconds * time.second)
}
*/

// sleep_ms makes the calling thread sleep for a given number of milliseconds.
[deprecated: 'call time.sleep(n * time.millisecond)']
pub fn sleep_ms(milliseconds int) {
	wait(milliseconds * time.millisecond)
}

// usleep makes the calling thread sleep for a given number of microseconds.
[deprecated: 'call time.sleep(n * time.microsecond)']
pub fn usleep(microseconds int) {
	wait(microseconds * time.microsecond)
}

// is_leap_year checks if a given a year is a leap year.
pub fn is_leap_year(year int) bool {
	return (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0)
}

// days_in_month returns a number of days in a given month.
pub fn days_in_month(month int, year int) ?int {
	if month > 12 || month < 1 {
		return error('Invalid month: $month')
	}
	extra := if month == 2 && is_leap_year(year) { 1 } else { 0 }
	res := time.month_days[month - 1] + extra
	return res
}

// str returns time in the same format as `parse` expects ("YYYY-MM-DD HH:MM:SS").
pub fn (t Time) str() string {
	// TODO Define common default format for
	// `str` and `parse` and use it in both ways
	return t.format_ss()
}

// A lot of these are taken from the Go library.
pub type Duration = i64

pub const (
	nanosecond  = Duration(1)
	microsecond = Duration(1000 * nanosecond)
	millisecond = Duration(1000 * microsecond)
	second      = Duration(1000 * millisecond)
	minute      = Duration(60 * second)
	hour        = Duration(60 * minute)
	infinite    = Duration(-1)
)

// nanoseconds returns the duration as an integer number of nanoseconds.
pub fn (d Duration) nanoseconds() i64 {
	return i64(d)
}

// microseconds returns the duration as an integer number of microseconds.
pub fn (d Duration) microseconds() i64 {
	return i64(d) / 1000
}

// milliseconds returns the duration as an integer number of milliseconds.
pub fn (d Duration) milliseconds() i64 {
	return i64(d) / 1000000
}

// The following functions return floating point numbers because it's common to
// consider all of them in sub-one intervals
// seconds returns the duration as a floating point number of seconds.
pub fn (d Duration) seconds() f64 {
	sec := d / time.second
	nsec := d % time.second
	return f64(sec) + f64(nsec) / 1e9
}

// minutes returns the duration as a floating point number of minutes.
pub fn (d Duration) minutes() f64 {
	min := d / time.minute
	nsec := d % time.minute
	return f64(min) + f64(nsec) / (60 * 1e9)
}

// hours returns the duration as a floating point number of hours.
pub fn (d Duration) hours() f64 {
	hr := d / time.hour
	nsec := d % time.hour
	return f64(hr) + f64(nsec) / (60 * 60 * 1e9)
}

// offset returns time zone UTC offset in seconds.
pub fn offset() int {
	return os_timezone_offset_seconds()
}
