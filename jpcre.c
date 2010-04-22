#include <stdio.h>
#include <string.h>
#include <pcre.h>
#include "jpcre.h"

char* matches(char* pattern, char* options, char* subject) {
    pcre *re;
    int rc;
    int opts;
    const char *error;
    int erroffset;
    int ovector[OVECCOUNT];
    int subject_length;
    int match;
    char *substring;
    int substring_length;
    char* result;

    opts = parse_options(options, &error, &erroffset);
    if (opts < 0) {
        asprintf(&result, "error:Error parsing options %s at offset %d: %s", options, erroffset, error);
        free(error);
        return result;
    }
    re = pcre_compile(pattern, opts, &error, &erroffset, NULL);
    if (re == NULL) {
        asprintf(&result, "error:Error compiling %s at offset %d: %s", pattern, erroffset, error);
        return result;
    }

    subject_length = (int)strlen(subject);
    rc = pcre_exec(re, NULL, subject, subject_length, 0, 0, ovector, OVECCOUNT);

    if (rc < 0) {
        switch (rc) {
            case PCRE_ERROR_NOMATCH:
                asprintf(&result, "success:0");
                break;;

            default:
                asprintf(&result, "error:Matching error: %d");
                break;;
        }
        pcre_free(re);
        return result;
    }

    if (rc == 0) {
        rc = OVECCOUNT/3;
    }

    match = rc - 1;
    substring = subject + ovector[2*match];
    substring_length = ovector[2*match+1] - ovector[2*match];
    asprintf(&result, "success:1,%.*s", substring_length, substring);
    pcre_free(re);
    return result;
}

int parse_options(char *options, char **error, int *erroffset) {
    int opts = 0;

    char *p = options;
    while (*p != 0) {
        switch (*p) {
            case 'f':
                opts |= PCRE_FIRSTLINE;
                break;
            case 'i':
                opts |= PCRE_CASELESS;
                break;
            case 'm':
                opts |= PCRE_MULTILINE;
                break;
            case 's':
                opts |= PCRE_DOTALL;
                break;
            case 'x':
                opts |= PCRE_EXTENDED;
                break;
            case 'A':
                opts |= PCRE_ANCHORED;
                break;
            case 'C':
                opts |= PCRE_AUTO_CALLOUT;
                break;
            case 'E':
                opts |= PCRE_DOLLAR_ENDONLY;
                break;
            case 'J':
                opts |= PCRE_DUPNAMES;
                break;
            case 'N':
                opts |= PCRE_NO_AUTO_CAPTURE;
                break;
            case 'U':
                opts |= PCRE_UNGREEDY;
                break;
            case 'X':
                opts |= PCRE_EXTRA;
                break;
            case '8':
                opts |= PCRE_UTF8;
                break;
            case '?':
                opts |= PCRE_NO_UTF8_CHECK;
                break;

            default:
                *erroffset = p - options;
                asprintf(error, "Invalid option %c", *p);
                return -1;
                break;
        }
        p++;
    }

    return opts;
}
