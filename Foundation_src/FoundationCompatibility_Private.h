
#ifndef FOUNDATION_PRIVATE_H
#define FOUNDATION_PRIVATE_H

#import "FoundationCompatibility_Public.h"

#import "MSFoundation_Public.h"

void FoundationCompatibilityExtendClass(char type, Class dstClass, SEL dstSel, Class srcClass, SEL srcSel);

#endif
