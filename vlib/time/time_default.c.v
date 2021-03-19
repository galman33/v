module time

#include <time.h>

fn C.time(t &C.time_t) C.time_t

fn os_unix_time_microseconds() i64 {
	return i64(C.time(0)) * microseconds_per_second
}