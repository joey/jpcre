%module RawJPcre
%{
#include "jpcre.h"
%}

%typemap(out) char * {
    if ($1) {
        jresult = (*jenv)->NewStringUTF(jenv, (const char*)$1);
        free($1);
    }
}
char* matches(char* pattern, char* options, char* subject);
