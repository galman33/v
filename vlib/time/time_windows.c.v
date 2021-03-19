module time

#include <time.h>

const (
	microseconds_per_tick = 10
	filetime_to_unix_epoch_in_microseconds = 11644473600000000
)

struct C._FILETIME {
	dwLowDateTime int
	dwHighDateTime int
}

fn C.GetSystemTimeAsFileTime(lpSystemTimeAsFileTime &C._FILETIME)

fn os_unix_time_microseconds() i64 {
	ft_utc := C._FILETIME{}
	C.GetSystemTimeAsFileTime(&ft_utc)
	file_time := (i64(ft_utc.dwHighDateTime) << 32) + i64(ft_utc.dwLowDateTime)
	return file_time / microseconds_per_tick - filetime_to_unix_epoch_in_microseconds
}