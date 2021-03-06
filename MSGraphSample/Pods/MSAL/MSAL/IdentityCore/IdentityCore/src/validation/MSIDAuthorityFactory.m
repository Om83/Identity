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

#import "MSIDAuthorityFactory.h"
#import "MSIDAADAuthority.h"
#import "MSIDADFSAuthority.h"
#import "MSIDB2CAuthority.h"
#import "MSIDAuthority+Internal.h"

@implementation MSIDAuthorityFactory

+ (MSIDAuthority *)authorityFromUrl:(NSURL *)url
                               context:(id<MSIDRequestContext>)context
                                 error:(NSError **)error
{
    return [self authorityFromUrl:url rawTenant:nil context:context error:error];
}

+ (MSIDAuthority *)authorityFromUrl:(NSURL *)url
                          rawTenant:(NSString *)rawTenant
                            context:(id<MSIDRequestContext>)context
                              error:(NSError **)error
{
    NSError *underlyingError;
    if ([MSIDB2CAuthority isAuthorityFormatValid:url context:context error:nil])
    {
        __auto_type b2cAuthority = [[MSIDB2CAuthority alloc] initWithURL:url rawTenant:rawTenant context:context error:&underlyingError];
        if (b2cAuthority) return b2cAuthority;
    }
    
    if ([MSIDADFSAuthority isAuthorityFormatValid:url context:context error:nil])
    {
        __auto_type adfsAuthority = [[MSIDADFSAuthority alloc] initWithURL:url context:context error:&underlyingError];
        if (adfsAuthority) return adfsAuthority;
    }
    
    if ([MSIDAADAuthority isAuthorityFormatValid:url context:context error:nil])
    {
        __auto_type aadAuthority = [[MSIDAADAuthority alloc] initWithURL:url rawTenant:rawTenant context:context error:&underlyingError];
        if (aadAuthority) return aadAuthority;
    }
    
    if (error)
    {
        *error = MSIDCreateError(MSIDErrorDomain, MSIDErrorInvalidDeveloperParameter, @"Provided authority url is not a valid authority.", nil, nil, underlyingError, context.correlationId, nil);
        
        MSID_LOG_ERROR(context, @"Provided authority url is not a valid authority.");
    }
    
    return nil;
}

+ (MSIDAuthority *)authorityWithRawTenant:(NSString *)rawTenant
                            msidAuthority:(MSIDAuthority *)msidAuthority
                                  context:(id<MSIDRequestContext>)context
                                    error:(NSError **)error
{
    if ([msidAuthority isKindOfClass:[MSIDB2CAuthority class]])
    {
        MSIDB2CAuthority *b2cAuthority = [[MSIDB2CAuthority alloc] initWithURL:msidAuthority.url rawTenant:rawTenant context:context error:error];
        
        if (b2cAuthority)
        {
            return b2cAuthority;
        }
        
        return [[MSIDB2CAuthority alloc] initWithURL:msidAuthority.url validateFormat:NO context:context error:error];
    }
    
    return [self authorityFromUrl:msidAuthority.url rawTenant:rawTenant context:context error:error];
}

@end
