#include "MSStd_Private.h"

#if defined(UNIX)

#include <uuid/uuid.h>
void ms_generate_uuid(char dst[37])
{
  uuid_t uuid;
  uuid_generate_random ( uuid );
  uuid_unparse ( uuid, dst );
}

#elif defined(WIN32)

#include <Rpc.h>
#include <string.h>
void ms_generate_uuid(char dst[37])
{
  unsigned char *str;
  UUID uuid;
  UuidCreate(&uuid);
  UuidToString(&uuid, &str);
  strncpy_s(dst, 37, (const char *)str, 37);
  RpcStringFree(&str);
}

#else
#error MSStd uuid platform not supported
#endif

#if defined(MSVC)
/*
 * strtok_r code directly from glibc.git /string/strtok_r.c since windows
 * doesn't have it.
 */
char *strtok_r(char *s, const char *delim, char **save_ptr)
{
    char *token;
    
    if(s == NULL)
        s = *save_ptr;
    
    /* Scan leading delimiters.  */
    s += strspn(s, delim);
    if(*s == '\0')
    {
        *save_ptr = s;
        return NULL;
    }
    
    /* Find the end of the token.  */
    token = s;
    s = strpbrk(token, delim);
    
    if(s == NULL)
    {
        /* This token finishes the string.  */
        *save_ptr = strchr(token, '\0');
    }
    else
    {
        /* Terminate the token and make *SAVE_PTR point past it.  */
        *s = '\0';
        *save_ptr = s + 1;
    }
    
    return token;
}
#endif
  
#if defined(WIN32) && !defined(__MINGW32__)
int snprintf(char *str, size_t size, const char *format, ...)
{
  int ret;
  va_list ap;
  va_start(ap, format);
  ret = (int)vsnprintf_s(str, size, size, format, ap);
  va_end(ap);
  return ret;
}
#endif

#if defined(WO451)
int vsnprintf(char *str, size_t size, const char *format, va_list ap)
{ 
  return _vsnprintf(str, size, format, ap); 
}

#endif
