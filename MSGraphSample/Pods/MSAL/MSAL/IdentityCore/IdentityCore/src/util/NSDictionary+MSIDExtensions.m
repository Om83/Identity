// Copyright (c) Microsoft Corporation.
// All rights reserved.
//
// This code is licensed under the MIT License.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files(the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions :
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import "NSDictionary+MSIDExtensions.h"
#import "NSString+MSIDExtensions.h"

@implementation NSDictionary (MSIDExtensions)

+ (NSDictionary *)msidDictionaryFromURLEncodedString:(NSString *)string
{
    return [self msidDictionaryFromURLEncodedString:string isFormEncoded:NO];
}

// Decodes a www-form-urlencoded string into a dictionary of key/value pairs.
// Always returns a dictionary, even if the string is nil, empty or contains no pairs
+ (NSDictionary *)msidDictionaryFromWWWFormURLEncodedString:(NSString *)string
{
    return [self msidDictionaryFromURLEncodedString:string isFormEncoded:YES];
}

+ (NSDictionary *)msidDictionaryFromURLEncodedString:(NSString *)string
                                       isFormEncoded:(BOOL)isFormEncoded
{
    if ([NSString msidIsStringNilOrBlank:string])
    {
        return nil;
    }
    
    NSArray *queries = [string componentsSeparatedByString:@"&"];
    NSMutableDictionary *queryDict = [NSMutableDictionary new];
    
    for (NSString *query in queries)
    {
        NSArray *queryElements = [query componentsSeparatedByString:@"="];
        if (queryElements.count > 2)
        {
            MSID_LOG_WARN(nil, @"Query parameter must be a form key=value: %@", query);
            continue;
        }
        
        NSString *key = isFormEncoded ? [queryElements[0] msidTrimmedString].msidWWWFormURLDecode : [queryElements[0] msidTrimmedString].msidURLDecode;
        if ([NSString msidIsStringNilOrBlank:key])
        {
            MSID_LOG_WARN(nil, @"Query parameter must have a key");
            continue;
        }
        
        NSString *value = @"";
        if (queryElements.count == 2)
        {
            value = isFormEncoded ? [queryElements[1] msidTrimmedString].msidWWWFormURLDecode : [queryElements[1] msidTrimmedString].msidURLDecode;
        }
        
        [queryDict setValue:value forKey:key];
    }
    
    return queryDict;
}

+ (NSDictionary *)msidDictionaryFromJsonData:(NSData *)data error:(NSError **)error
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingMutableContainers
                                                           error:error];
    
    return json;
}

- (NSString *)msidURLEncode
{
    return [NSString msidURLEncodedStringFromDictionary:self];
}

- (NSString *)msidWWWFormURLEncode
{
    return [NSString msidWWWFormURLEncodedStringFromDictionary:self];
}


- (NSDictionary *)dictionaryByRemovingFields:(NSArray *)fieldsToRemove
{
    NSMutableDictionary *mutableDict = [self mutableCopy];
    [mutableDict removeObjectsForKeys:fieldsToRemove];
    return mutableDict;
}


- (BOOL)msidAssertType:(Class)type
               ofField:(NSString *)field
               context:(id <MSIDRequestContext>)context
             errorCode:(NSInteger)errorCode
                 error:(NSError **)error
{
    id fieldValue = self[field];
    if (![fieldValue isKindOfClass:type])
    {
        __auto_type message = [NSString stringWithFormat:@"%@ is not a %@.", field, type];
        
        if (error)
        {
            *error = MSIDCreateError(MSIDErrorDomain,
                                     errorCode,
                                     message,
                                     nil,
                                     nil, nil, context.correlationId, nil);
        }
        
        MSID_LOG_ERROR(nil, @"%@", message);
        return NO;
    }
    
    return YES;
}

- (BOOL)msidAssertContainsField:(NSString *)field
                        context:(id <MSIDRequestContext>)context
                          error:(NSError **)error
{
    id fieldValue = self[field];
    if (!fieldValue)
    {
        __auto_type message = [NSString stringWithFormat:@"%@ is missing.", field];
        
        if (error)
        {
            *error = MSIDCreateError(MSIDErrorDomain,
                                     MSIDErrorServerInvalidResponse,
                                     message,
                                     nil,
                                     nil, nil, context.correlationId, nil);
        }
        
        MSID_LOG_ERROR(nil, @"%@", message);
        return NO;
    }
    
    return YES;
}

- (NSString *)msidJSONSerializeWithContext:(id<MSIDRequestContext>)context
{
    NSError *serializationError = nil;
    NSData *serializedData = [NSJSONSerialization dataWithJSONObject:self options:0 error:&serializationError];

    if (!serializedData)
    {
        MSID_LOG_NO_PII(MSIDLogLevelWarning, nil, context, @"Failed to serialize data with error %ld, %@", (long)serializationError.code, serializationError.domain);
        MSID_LOG_PII(MSIDLogLevelWarning, nil, context, @"Failed to serialize data with error %@", serializationError);
        
        return nil;
    }

    return [[NSString alloc] initWithData:serializedData encoding:NSUTF8StringEncoding];
}

// TODO: verify this is still necessary as it was done in ADAL
- (NSDictionary *)msidDictionaryWithoutNulls
{
    NSMutableDictionary *cleanedDictionary = [NSMutableDictionary new];

    for (NSString *key in self.allKeys)
    {
        NSString *val = [self valueForKey:key];

        if ([val isKindOfClass:[NSString class]]
            && ![val isEqualToString:@"(null)"])
        {
            cleanedDictionary[key] = val;
        }
    }

    return cleanedDictionary;
}

@end
