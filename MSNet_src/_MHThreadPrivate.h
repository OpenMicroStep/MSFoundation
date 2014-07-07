/*
 
 MSThread.h
 
 This file is is a part of the MicroStep Application Server over Http Framework.

 Initial copyright LOGITUD Solutions (logitud@logitud.fr) since 2012
 
 Nicolas Surribas : nicolas.surribas@gmail.com
 
 This software is a computer program whose purpose is to [describe
 functionalities and technical features of your software].
 
 This software is governed by the CeCILL-C license under French law and
 abiding by the rules of distribution of free software.  You can  use, 
 modify and/ or redistribute the software under the terms of the CeCILL-C
 license as circulated by CEA, CNRS and INRIA at the following URL
 "http://www.cecill.info". 
 
 As a counterpart to the access to the source code and  rights to copy,
 modify and redistribute granted by the license, users are provided only
 with a limited warranty  and the software's author,  the holder of the
 economic rights,  and the successive licensors  have only  limited
 liability. 
 
 In this respect, the user's attention is drawn to the risks associated
 with loading,  using,  modifying and/or developing or reproducing the
 software by the user in light of its specific status of free software,
 that may mean  that it is complicated to manipulate,  and  that  also
 therefore means  that it is reserved for developers  and  experienced
 professionals having in-depth computer knowledge. Users are therefore
 encouraged to load and test the software's suitability as regards their
 requirements in conditions enabling the security of their systems and/or 
 data to be ensured and,  more generally, to use and operate it in the 
 same conditions as regards security. 
 
 The fact that you are presently reading this means that you have had
 knowledge of the CeCILL-C license and that you accept its terms.
*/

#warning A revoir dans le Core

#ifndef MY_THREAD_H
#define MY_THREAD_H

#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <fcntl.h>
#include <time.h>

#ifdef WIN32
//  #include <winsock.h>
  #include <io.h>
  #include <windows.h>
  #include <process.h>
  // Definition of threads
  #define callback_t                       unsigned __stdcall
  #define thread_t                         HANDLE
  // thread_create return 0 on error, 1 on success
  #define thread_create(thrd, fct, param)  ((thrd = (HANDLE)_beginthreadex(NULL, 0, fct, (param), 0, NULL))?1:0)
  #define thread_delete(thrd)              CloseHandle(thrd)
  #define thread_wait_close(thrd)          WaitForMultipleObjects(1, &thrd, TRUE, INFINITE)
  #define thread_self()                    GetCurrentThread()
  #define thread_id()                      (unsigned int)GetCurrentThreadId()
  
  // Definition of semaphores
  #define semaphore_t                      HANDLE
  #define semaphore_init(sema,name,init,max)  ((sema) = CreateSemaphore(NULL, init, max, NULL))
  #define semaphore_lock(sema)             WaitForSingleObject(sema, INFINITE) // return 0 on success
  #define semaphore_unlock(sema)           ReleaseSemaphore(sema, 1, NULL)
  #define semaphore_delete(sema,name)      CloseHandle(sema)

  // Definition of events
  #define event_t                          HANDLE
  #define event_create(evt,val)            ((evt) = CreateEvent(NULL, FALSE, val, NULL))
  #define event_wait(evt)                  WaitForSingleObject(evt, INFINITE)
  #define event_set(evt)                   SetEvent(evt)
  #define event_delete(evt)                CloseHandle(evt)

  #define timeout_t                        DWORD
  #define timeout_set(T,X)                 (T=X*1000)

  #define ECONNABORTED WSAECONNABORTED
  #define ECONNRESET   WSAECONNRESET
  #define ETIMEDOUT    WSAETIMEDOUT
  #define EINPROGRESS  WSAEINPROGRESS

  #define EWOULDBLOCK  WSAEWOULDBLOCK
  

  #ifndef S_ISREG
  #define S_ISREG(mode)  (((mode) & S_IFMT) == S_IFREG)
  #endif

  #define cerrno WSAGetLastError()
  #define strcasecmp   _stricmp
  #define strncasecmp  _strnicmp
  #define snprintf     _snprintf
  #define sleep(x) Sleep(x*1000)
  #define socket_cleanup() WSACleanup()
  #define socket_init()  { \
                  WSADATA wsadata; \
                  if (WSAStartup(MAKEWORD(2,2), &wsadata) != 0) { \
                    WSACleanup();                     \
                    printf("WSAStartup(): could not initialize Winsock\n");  \
                  } \
                }

#else
  #include <sys/time.h>
  #include <unistd.h>
  #include <pthread.h>
  #include <sys/socket.h>
  #include <arpa/inet.h>
  #include <semaphore.h>

  // Constants from Microsoft
  #define INFINITE         -1
  #define WAIT_OBJECT_0    0
  #define WAIT_TIMEOUT     64
  #define WAIT_FAILED      96
  #define WAIT_ABANDONED_0 128
  #define SOCKET_ERROR     -1
  #define INVALID_SOCKET   -1
  #define _S_IREAD 0000400   /* read permission, owner */
  #define _S_IWRITE 0000200  /* write permission, owner */
  #define _O_BINARY        0 /* Unset these constants on Linux */
  #define _O_SEQUENTIAL    0

  typedef struct sockaddr_in SOCKADDR_IN;
  typedef struct sockaddr SOCKADDR;
  typedef struct timeval timeout_t;
  #define closesocket(s) close (s) 
  #define socket_init() {}
  #define socket_cleanup() {}
  #define cerrno errno

  #define timeout_set(T,X)                 {T.tv_usec = 0; T.tv_sec = X;}

  // Definition of threads
  #define callback_t                       void * 
  #define thread_t                         pthread_t
  // thread_create return 0 on error, 1 on success
  #define thread_create(thrd, fct, param)  (!pthread_create(&thrd, NULL, (fct), ((void*)param)))
  #define thread_delete(thrd)              if ((pthread_t)thrd != (pthread_t)NULL) \
                                                                  pthread_detach(thrd)
  #define thread_wait_close(thrd)          pthread_join(thrd, NULL)
  #define thread_self                      pthread_self()
  #define thread_id()                      (unsigned int)pthread_self()

  // Definition of events
  typedef struct
  {
    pthread_mutex_t mutex;
    pthread_cond_t  condition;
    unsigned int    flag;
  } real_event_t;

  //typedef real_event_t *event_t;
  #define event_t                          real_event_t *

  event_t _create_event(event_t evt, int initval) ;
  int event_wait(event_t evt) ;
  void event_set(event_t evt) ;
  void event_delete(event_t evt) ;

  #define event_create(evt,initval)     (evt = _create_event(evt,initval))

#endif

#ifdef __linux__
  // Definition of semaphores for Linux
  #define semaphore_t                      sem_t
  #define semaphore_init(sema, name, init, max)  sem_init(&sema, 0, init)
  #define semaphore_lock(sema)             sem_wait(&sema) // return 0 on success
  #define semaphore_unlock(sema)           sem_post(&sema)
  #define semaphore_delete(sema,name)      sem_destroy(&sema)
#elif __APPLE__
  #include <sys/time.h>
  #include <unistd.h>
  #include <pthread.h>
  #include <sys/socket.h>
  #include <arpa/inet.h>
  #include <semaphore.h>

  // Definition of semaphores for Apple
  #define semaphore_t                      sem_t* // sem_init doesn't exists on Mac OS X

  semaphore_t _semaphore_init(unsigned int init, const char *name) ;

  #define semaphore_init(sema, name, init, max)  ((sema) = _semaphore_init(init, name))
  #define semaphore_lock(sema)             sem_wait(sema)
  #define semaphore_unlock(sema)           sem_post(sema)
  #define semaphore_delete(sema,name)      { sem_close(sema); sem_unlink(name); }
#endif

#endif
