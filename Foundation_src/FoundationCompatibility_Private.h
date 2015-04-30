
#ifndef FOUNDATION_PRIVATE_H
#define FOUNDATION_PRIVATE_H

#import "MSFoundation_Public.h"

#import <objc/encoding.h>

void FoundationCompatibilityExtendClass(char type, Class dstClass, SEL dstSel, Class srcClass, SEL srcSel);

#endif
