module time

#include <time.h>

fn C.QueryPerformanceCounter(&u64) C.BOOL
fn C.QueryPerformanceFrequency(&u64) C.BOOL

fn C.tzset()

fn C._get_timezone(mut seconds &u64) int

pub fn lol() {
	C.tzset()
	mut seconds := u64(0)
	C._get_timezone(mut &seconds)
	println(seconds)
}

const (
	// start_time is needed on Darwin and Windows because of potential overflows
	start_time       = init_win_time_start()
	freq_time        = init_win_time_freq()
)

fn init_win_time_freq() u64 {
	f := u64(0)
	C.QueryPerformanceFrequency(&f)
	return f
}

fn init_win_time_start() u64 {
	s := u64(0)
	C.QueryPerformanceCounter(&s)
	return s
}

// sys_mono_now returns a *monotonically increasing time*, NOT a time adjusted for daylight savings, location etc.
pub fn sys_mono_now() u64 {
	tm := u64(0)
	C.QueryPerformanceCounter(&tm) // XP or later never fail
	return (tm - time.start_time) * 1000000000 / time.freq_time
}

// wait makes the calling thread sleep for a given duration (in nanoseconds).
[deprecated: 'call time.sleep(n * time.second)']
pub fn wait(duration Duration) {
	C.Sleep(int(duration / millisecond))
}

// sleep makes the calling thread sleep for a given duration (in nanoseconds).
pub fn sleep(duration Duration) {
	C.Sleep(int(duration / millisecond))
}

struct C.tm {
	tm_year int
	tm_mon  int
	tm_mday int
	tm_hour int
	tm_min  int
	tm_sec  int
}

fn C.time(t &C.time_t) C.time_t
fn C.gmtime(timer &C.time_t) &C.tm
fn C.mktime(timeptr &C.tm) C.time_t

fn os_timezone_offset_seconds() int {
	utc_time := C.time(0)
	utc_tm := C.gmtime(&utc_time)
	utc_time_minus_offset := C.mktime(utc_tm)
	return int(utc_time) - int(utc_time_minus_offset)
}