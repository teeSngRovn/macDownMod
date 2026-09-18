#import <Foundation/Foundation.h>

@interface MPSyntaxExtensions : NSObject

// Converts configured delimiters to the math delimiters understood by Hoedown.
+ (NSString *)markdownByApplyingRulesToMarkdown:(NSString *)markdown
                                     mathEnabled:(BOOL)mathEnabled;

@end
