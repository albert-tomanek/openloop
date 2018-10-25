#include "nanosleephelper.h"

void vala_nanosleep(time_t sec, uint64_t nsec)
{
	struct timespec t;
	t.tv_sec  = sec;
	t.tv_nsec = nsec;

	nanosleep(&t, NULL);
}
