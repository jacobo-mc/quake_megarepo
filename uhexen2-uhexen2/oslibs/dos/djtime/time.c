#include <time.h>

time_t time (time_t * tloc)
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    if (tloc)
        *tloc = tv.tv_sec;
    return tv.tv_sec;
}
