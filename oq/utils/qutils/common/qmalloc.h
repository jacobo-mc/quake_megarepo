#ifndef QMALLOC_H
#define QMALLOC_H

void *Q_malloc(size_t size);
void *Q_realloc(void *ptr,size_t size);
void  Q_free(void *ptr);

#endif

