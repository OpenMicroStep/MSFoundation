/**
 * libobjc requires recursive mutexes.  These are delegated to the underlying
 * threading implementation.
 */

#ifndef __LIBOBJC_LOCK_H_INCLUDED__
#define __LIBOBJC_LOCK_H_INCLUDED__

#include "MSStd.h"

// If this pthread implementation has a static initializer for recursive
// mutexes, use that, otherwise fall back to the portable version
#define INIT_LOCK(x) mtx_init(&(x), mtx_recursive)

#	define LOCK(x) mtx_lock(x)
#	define UNLOCK(x) mtx_unlock(x)
#	define DESTROY_LOCK(x) mtx_destroy(x)

__attribute__((unused)) static void objc_release_lock(void *x)
{
	mtx_t *lock = *(mtx_t**)x;
	mtx_unlock(lock);
}
/**
 * Acquires the lock and automatically releases it at the end of the current
 * scope.
 */
#define LOCK_FOR_SCOPE(lock) \
	__attribute__((cleanup(objc_release_lock)))\
	__attribute__((unused)) mtx_t *lock_pointer = lock;\
	LOCK(lock)

/**
 * The global runtime mutex.
 */
extern mtx_t runtime_mutex;

#define LOCK_RUNTIME() LOCK(&runtime_mutex)
#define UNLOCK_RUNTIME() UNLOCK(&runtime_mutex)
#define LOCK_RUNTIME_FOR_SCOPE() LOCK_FOR_SCOPE(&runtime_mutex)

#endif // __LIBOBJC_LOCK_H_INCLUDED__
