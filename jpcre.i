%module RawJPcre
%{
#include "jpcre.h"
%}

char* matches(char* pattern, char* options, char* subject);
