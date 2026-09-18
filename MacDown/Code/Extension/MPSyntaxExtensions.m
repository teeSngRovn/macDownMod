#import "MPSyntaxExtensions.h"
#import "MPUtilities.h"

static BOOL MPHasUnescapedToken(NSString *text, NSString *token, NSUInteger index)
{
    if (index + token.length > text.length ||
        ![[text substringWithRange:NSMakeRange(index, token.length)] isEqualToString:token])
        return NO;

    NSUInteger slashes = 0;
    while (index > slashes && [text characterAtIndex:index - slashes - 1] == '\\')
        slashes++;
    return slashes % 2 == 0;
}

static NSRange MPFindClosingToken(NSString *text, NSString *token, NSUInteger start)
{
    while (start < text.length)
    {
        NSRange range = [text rangeOfString:token options:0
                                    range:NSMakeRange(start, text.length - start)];
        if (range.location == NSNotFound)
            return range;
        if (MPHasUnescapedToken(text, token, range.location))
            return range;
        start = NSMaxRange(range);
    }
    return NSMakeRange(NSNotFound, 0);
}

static NSArray<NSDictionary *> *MPLoadSyntaxRules(void)
{
    NSString *bundled = [[[NSBundle mainBundle] resourcePath]
                         stringByAppendingPathComponent:@"Extensions"];
    NSString *user = MPDataDirectory(@"SyntaxExtensions");
    NSMutableDictionary<NSString *, NSString *> *files = [NSMutableDictionary dictionary];
    NSFileManager *manager = [NSFileManager defaultManager];
    for (NSString *directory in @[bundled, user])
    {
        NSArray<NSString *> *names = [[manager contentsOfDirectoryAtPath:directory error:NULL]
                                      sortedArrayUsingSelector:@selector(compare:)];
        for (NSString *name in names)
            if ([name hasSuffix:@".syntax.json"])
                files[name] = [directory stringByAppendingPathComponent:name];
    }

    NSMutableArray<NSDictionary *> *rules = [NSMutableArray array];
    for (NSString *name in [[files allKeys] sortedArrayUsingSelector:@selector(compare:)])
    {
        NSData *data = [NSData dataWithContentsOfFile:files[name]];
        NSDictionary *definition = data ? [NSJSONSerialization JSONObjectWithData:data
                                                                          options:0 error:NULL] : nil;
        if (![definition isKindOfClass:[NSDictionary class]])
        {
            NSLog(@"Invalid syntax extension: %@", files[name]);
            continue;
        }
        if ([definition[@"enabled"] isKindOfClass:[NSNumber class]] &&
            ![definition[@"enabled"] boolValue])
            continue;
        if (![definition[@"rules"] isKindOfClass:[NSArray class]])
            continue;

        for (id entry in definition[@"rules"])
        {
            if (![entry isKindOfClass:[NSDictionary class]])
                continue;
            NSString *opening = entry[@"open"];
            NSString *closing = entry[@"close"];
            NSString *kind = entry[@"kind"];
            if (![opening isKindOfClass:[NSString class]] || !opening.length ||
                ![closing isKindOfClass:[NSString class]] || !closing.length ||
                ![kind isKindOfClass:[NSString class]] ||
                !([kind isEqualToString:@"displayMath"] ||
                  [kind isEqualToString:@"inlineMath"]))
                continue;
            [rules addObject:entry];
        }
    }
    [rules sortUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) {
        NSUInteger first = [a[@"open"] length];
        NSUInteger second = [b[@"open"] length];
        if (first > second) return NSOrderedAscending;
        if (first < second) return NSOrderedDescending;
        return NSOrderedSame;
    }];
    return rules;
}

static NSUInteger MPLineEnd(NSString *text, NSUInteger start)
{
    NSRange newline = [text rangeOfString:@"\n" options:0
                                  range:NSMakeRange(start, text.length - start)];
    return newline.location == NSNotFound ? text.length : NSMaxRange(newline);
}

static NSUInteger MPFenceLength(NSString *text, NSUInteger start, NSUInteger end,
                               unichar *marker, BOOL *onlyWhitespaceAfter)
{
    NSUInteger position = start;
    while (position < end && position - start < 4 && [text characterAtIndex:position] == ' ')
        position++;
    if (position - start > 3 || position == end)
        return 0;
    unichar character = [text characterAtIndex:position];
    if (character != '`' && character != '~')
        return 0;
    NSUInteger runStart = position;
    while (position < end && [text characterAtIndex:position] == character)
        position++;
    NSUInteger count = position - runStart;
    if (count < 3)
        return 0;
    *marker = character;
    *onlyWhitespaceAfter = YES;
    while (position < end)
    {
        unichar current = [text characterAtIndex:position++];
        if (current != ' ' && current != '\t' && current != '\r' && current != '\n')
            *onlyWhitespaceAfter = NO;
    }
    return count;
}

@implementation MPSyntaxExtensions

+ (NSString *)markdownByApplyingRulesToMarkdown:(NSString *)markdown
                                     mathEnabled:(BOOL)mathEnabled
{
    if (!mathEnabled || !markdown.length)
        return markdown;
    NSArray<NSDictionary *> *rules = MPLoadSyntaxRules();
    if (!rules.count)
        return markdown;

    NSMutableString *result = [NSMutableString stringWithCapacity:markdown.length];
    NSUInteger position = 0;
    BOOL lineStart = YES;
    unichar fence = 0;
    NSUInteger fenceLength = 0;

    while (position < markdown.length)
    {
        if (lineStart)
        {
            NSUInteger end = MPLineEnd(markdown, position);
            unichar marker = 0;
            BOOL whitespaceAfter = NO;
            NSUInteger count = MPFenceLength(markdown, position, end,
                                            &marker, &whitespaceAfter);
            if (fence)
            {
                if (marker == fence && count >= fenceLength && whitespaceAfter)
                {
                    fence = 0;
                    fenceLength = 0;
                }
                [result appendString:[markdown substringWithRange:NSMakeRange(position, end - position)]];
                position = end;
                continue;
            }
            if (count >= 3)
            {
                fence = marker;
                fenceLength = count;
                [result appendString:[markdown substringWithRange:NSMakeRange(position, end - position)]];
                position = end;
                continue;
            }
            if ([markdown characterAtIndex:position] == '\t' ||
                (end - position >= 4 && [[markdown substringWithRange:NSMakeRange(position, 4)]
                                          isEqualToString:@"    "]))
            {
                [result appendString:[markdown substringWithRange:NSMakeRange(position, end - position)]];
                position = end;
                continue;
            }
            lineStart = NO;
        }

        unichar current = [markdown characterAtIndex:position];
        if (current == '\n')
        {
            [result appendString:@"\n"];
            position++;
            lineStart = YES;
            continue;
        }
        if (current == '`' && MPHasUnescapedToken(markdown, @"`", position))
        {
            NSUInteger count = 1;
            while (position + count < markdown.length &&
                   [markdown characterAtIndex:position + count] == '`')
                count++;
            NSString *delimiter = [@"" stringByPaddingToLength:count withString:@"`" startingAtIndex:0];
            NSRange close = [markdown rangeOfString:delimiter options:0
                                            range:NSMakeRange(position + count,
                                                              markdown.length - position - count)];
            if (close.location != NSNotFound)
            {
                NSUInteger end = NSMaxRange(close);
                [result appendString:[markdown substringWithRange:NSMakeRange(position, end - position)]];
                lineStart = [markdown characterAtIndex:end - 1] == '\n';
                position = end;
                continue;
            }
        }
        if (current == '<')
        {
            BOOL skippedRawElement = NO;
            for (NSString *tag in @[@"pre", @"code", @"script", @"style"])
            {
                NSString *opening = [NSString stringWithFormat:@"<%@", tag];
                if (position + opening.length > markdown.length ||
                    [[markdown substringWithRange:NSMakeRange(position, opening.length)]
                     caseInsensitiveCompare:opening] != NSOrderedSame)
                    continue;
                NSUInteger afterName = position + opening.length;
                if (afterName < markdown.length &&
                    [markdown characterAtIndex:afterName] != '>' &&
                    [markdown characterAtIndex:afterName] != ' ')
                    continue;
                NSString *closing = [NSString stringWithFormat:@"</%@>", tag];
                NSRange endTag = [markdown rangeOfString:closing
                                                options:NSCaseInsensitiveSearch
                                                  range:NSMakeRange(position, markdown.length - position)];
                if (endTag.location != NSNotFound)
                {
                    NSUInteger end = NSMaxRange(endTag);
                    [result appendString:[markdown substringWithRange:NSMakeRange(position, end - position)]];
                    position = end;
                    skippedRawElement = YES;
                }
                break;
            }
            if (skippedRawElement)
                continue;
            NSRange tagEnd = [markdown rangeOfString:@">" options:0
                                             range:NSMakeRange(position, markdown.length - position)];
            if (tagEnd.location != NSNotFound)
            {
                NSUInteger end = NSMaxRange(tagEnd);
                [result appendString:[markdown substringWithRange:NSMakeRange(position, end - position)]];
                position = end;
                continue;
            }
        }

        BOOL matched = NO;
        for (NSDictionary *rule in rules)
        {
            NSString *opening = rule[@"open"];
            if (!MPHasUnescapedToken(markdown, opening, position))
                continue;
            NSString *closing = rule[@"close"];
            NSRange end = MPFindClosingToken(markdown, closing, position + opening.length);
            if (end.location == NSNotFound)
                continue;
            BOOL display = [rule[@"kind"] isEqualToString:@"displayMath"];
            // Hoedown 3.0.7 parses doubled backslash delimiters natively.
            // Keep that compatibility detail here rather than editing the pod.
            [result appendString:display ? @"\\\\[" : @"\\\\("];
            [result appendString:[markdown substringWithRange:
                                  NSMakeRange(position + opening.length,
                                              end.location - position - opening.length)]];
            [result appendString:display ? @"\\\\]" : @"\\\\)"];
            position = NSMaxRange(end);
            matched = YES;
            break;
        }
        if (matched)
            continue;
        [result appendFormat:@"%C", current];
        position++;
    }
    return result;
}

@end
