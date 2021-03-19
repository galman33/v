module time

// operator `==` returns true if provided time is equal to time
[inline]
pub fn (t1 Time) == (t2 Time) bool {
	return t1.unix_microseconds == t2.unix_microseconds
}

// operator `<` returns true if provided time is less than time
[inline]
pub fn (t1 Time) < (t2 Time) bool {
	return t1.unix_microseconds < t2.unix_microseconds
}

// Time subtract using operator overloading.
[inline]
pub fn (lhs Time) - (rhs Time) Duration {
	return (lhs.unix_microseconds - rhs.unix_microseconds) * microsecond
}
