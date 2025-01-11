#pragma once
#include "config.h"

#ifdef DEV_BUILD
    #define BUILD_TYPE "development"
#else
    #define BUILD_TYPE "production"
#endif

#define AEGIS_VERSION VERSION 