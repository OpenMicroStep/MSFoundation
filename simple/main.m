#import <MSFoundation/MSFoundation.h>

//#define testAssert imp_testAssert
//#import "MSTests.h"

int main(int argc, const char * argv[]) {
  id c;
  printf("Hello, World!\n");
  [MSArray array];
  printf("A\n");
  c= MSAliceBlue;
  printf("A1 %p %d %d %d\n",c,[c red],[c green],[c blue]);
  c= MSColorNamed(@"AliceBlue");
  printf("A2 %p %d %d %d\n",c,[c red],[c green],[c blue]);
  c= [MSColor colorWithName:@"AliceBlue"];
  printf("A3 %p %d %d %d\n",c,[c red],[c green],[c blue]);

//TASSERT_EQUALS([MSAliceBlue                          red], 240, "MSAliceBlue red: %d != 240");
//TASSERT_EQUALS([MSColorNamed(@"AliceBlue")           red], 240, "MSAliceBlue red: %d != 240");
//TASSERT_EQUALS([[MSColor colorWithName:@"AliceBlue"] red], 240, "MSAliceBlue red: %d != 240");

  return 0;
}
