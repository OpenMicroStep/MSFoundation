//
//  main.c
//  MSTests
//
//  Created by Vincent Rouillé on 27/01/2015.
//  Copyright (c) 2015 OpenMicroStep. All rights reserved.
//

#include "CommonDefines.h"
#include "MSTests.h"

int main(int argc, const char * argv[]) {
    for(int argi= 1; argi < argc; ++argi) {
        const char *module = argv[argi];
        char path[strlen(module) + strlen("libTests.dylib")];
        strcpy(path, "lib");
        strcpy(path + 3, module);
        strcpy(path + 3 + strlen(module), "Tests.dylib");
        printf("Loading tests for %s (%s)\n", module, path);
        
        dl_handle_t *testLib = dlopen(path, RTLD_LAZY);
        if(!testLib) {
            printf("Unable to load lib %s\n", path);
        }
        else {
            void *getSuites, *getDependencies;
            if(!(getSuites= dlsym(testLib, "testSuites"))) {
                printf("Unable to find test suites\n");
            }
            else if(!(getDependencies= dlsym(testLib, "parentTests"))) {
                printf("Unable to find dependencies\n");
            }
            else {
                test_suite_t ** suites;
                char **dependencies;
            }
            dlclose(testLib);
        }
    }
    return 0;
}
