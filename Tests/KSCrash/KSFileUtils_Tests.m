//
//  KSFileUtils_Tests.m
//
//  Created by Karl Stenerud on 2012-01-28.
//
//  Copyright (c) 2012 Karl Stenerud. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall remain in place
// in this source code.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//


#import "FileBasedTestCase.h"

#import "BSG_KSFileUtils.h"


@interface KSFileUtils_Tests : FileBasedTestCase @end


@implementation KSFileUtils_Tests

- (void) testLastPathEntry
{
    NSString* path = @"some/kind/of/path";
    NSString* expected = @"path";
    NSString* actual = [NSString stringWithCString:bsg_ksfulastPathEntry([path cStringUsingEncoding:NSUTF8StringEncoding])
                                          encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(actual, expected, @"");
}

- (void) testWriteBytesToFD
{
    NSError* error = nil;
    NSString* path = [self.tempPath stringByAppendingPathComponent:@"test.txt"];
    NSString* expected = @"testing a bunch of stuff.\nOh look, a newline!";
    int stringLength = (int)[expected length];

    int fd = open([path UTF8String], O_RDWR | O_CREAT | O_EXCL, 0644);
    XCTAssertTrue(fd >= 0, @"");
    bool result = bsg_ksfuwriteBytesToFD(fd, [expected cStringUsingEncoding:NSUTF8StringEncoding], stringLength);
    XCTAssertTrue(result, @"");
    bsg_ksfuflushWriteBuffer(fd);
    NSString* actual = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    XCTAssertNil(error, @"");
    XCTAssertEqualObjects(actual, expected, @"");
}

//- (void) testWriteBytesToFDBig
//{
//    NSError* error = nil;
//    NSString* path = [self.tempPath stringByAppendingPathComponent:@"test.txt"];
//    int length = 1000000;
//    NSMutableData* expected = [NSMutableData dataWithCapacity:(NSUInteger)length];
//    for(int i = 0; i < length; i++)
//    {
//        unsigned char byte = (unsigned char)i;
//        [expected appendBytes:&byte length:1];
//    }
//
//    int fd = open([path UTF8String], O_RDWR | O_CREAT | O_EXCL, 0644);
//    XCTAssertTrue(fd >= 0, @"");
//    bool result = bsg_ksfuwriteBytesToFD(fd, [expected bytes], length);
//    XCTAssertTrue(result, @"");
//    NSMutableData* actual = [NSMutableData dataWithContentsOfFile:path options:0 error:&error];
//    XCTAssertNil(error, @"");
//    XCTAssertEqualObjects(actual, expected, @"");
//}

- (void) testReadBytesFromFD
{
    NSError* error = nil;
    NSString* path = [self.tempPath stringByAppendingPathComponent:@"test.txt"];
    NSString* expected = @"testing a bunch of stuff.\nOh look, a newline!";
    int stringLength = (int)[expected length];
    [expected writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    XCTAssertNil(error, @"");

    int fd = open([path UTF8String], O_RDONLY);
    XCTAssertTrue(fd >= 0, @"");
    NSMutableData* data = [NSMutableData dataWithLength:(NSUInteger)stringLength];
    bool result = bsg_ksfureadBytesFromFD(fd, [data mutableBytes], stringLength);
    XCTAssertTrue(result, @"");
    NSString* actual = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    XCTAssertNil(error, @"");
    XCTAssertEqualObjects(actual, expected, @"");
}

//- (void) testReadBytesFromFDBig
//{
//    NSError* error = nil;
//    NSString* path = [self.tempPath stringByAppendingPathComponent:@"test.txt"];
//    int length = 1000000;
//    NSMutableData* expected = [NSMutableData dataWithCapacity:(NSUInteger)length];
//    for(int i = 0; i < length; i++)
//    {
//        unsigned char byte = (unsigned char)i;
//        [expected appendBytes:&byte length:1];
//    }
//    [expected writeToFile:path options:0 error:&error];
//    XCTAssertNil(error, @"");
//
//    int fd = open([path UTF8String], O_RDONLY);
//    XCTAssertTrue(fd >= 0, @"");
//    NSMutableData* actual = [NSMutableData dataWithLength:(NSUInteger)length];
//    bool result = bsg_ksfureadBytesFromFD(fd, [actual mutableBytes], length);
//    XCTAssertTrue(result, @"");
//    XCTAssertEqualObjects(actual, expected, @"");
//}

- (void) testReadEntireFile
{
    NSError* error = nil;
    NSString* path = [self.tempPath stringByAppendingPathComponent:@"test.txt"];
    NSString* expected = @"testing a bunch of stuff.\nOh look, a newline!";
    [expected writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    XCTAssertNil(error, @"");

    int fd = open([path UTF8String], O_RDONLY);
    XCTAssertTrue(fd >= 0, @"");
    char* bytes;
    size_t readLength;
    bool result = bsg_ksfureadEntireFile([path UTF8String], &bytes, &readLength);
    XCTAssertTrue(result, @"");
    NSMutableData* data = [NSMutableData dataWithBytesNoCopy:bytes length:readLength freeWhenDone:YES];
    NSString* actual = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    XCTAssertNil(error, @"");
    XCTAssertEqualObjects(actual, expected, @"");
}

- (void) testReadEntireFileBig
{
    NSError* error = nil;
    NSString* path = [self.tempPath stringByAppendingPathComponent:@"test.txt"];
    int length = 1000000;
    NSMutableData* expected = [NSMutableData dataWithCapacity:(NSUInteger)length];
    for(int i = 0; i < length; i++)
    {
        unsigned char byte = (unsigned char)i;
        [expected appendBytes:&byte length:1];
    }
    [expected writeToFile:path options:0 error:&error];
    XCTAssertNil(error, @"");

    int fd = open([path UTF8String], O_RDONLY);
    XCTAssertTrue(fd >= 0, @"");
    char* bytes;
    size_t readLength;
    bool result = bsg_ksfureadEntireFile([path UTF8String], &bytes, &readLength);
    XCTAssertTrue(result, @"");
    NSMutableData* actual = [NSMutableData dataWithBytesNoCopy:bytes length:readLength freeWhenDone:YES];
    XCTAssertEqualObjects(actual, expected, @"");
}

- (void) testWriteStringToFD
{
    NSError* error = nil;
    NSString* path = [self.tempPath stringByAppendingPathComponent:@"test.txt"];
    NSString* expected = @"testing a bunch of stuff.\nOh look, a newline!";

    int fd = open([path UTF8String], O_RDWR | O_CREAT | O_EXCL, 0644);
    XCTAssertTrue(fd >= 0, @"");
    bool result = bsg_ksfuwriteStringToFD(fd, [expected cStringUsingEncoding:NSUTF8StringEncoding]);
    XCTAssertTrue(result, @"");
    NSString* actual = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    XCTAssertNil(error, @"");
    XCTAssertEqualObjects(actual, expected, @"");
}

- (void) testWriteFmtToFD
{
    NSError* error = nil;
    NSString* path = [self.tempPath stringByAppendingPathComponent:@"test.txt"];
    NSString* expected = @"test test testing 1 2.0 3";

    int fd = open([path UTF8String], O_RDWR | O_CREAT | O_EXCL, 0644);
    XCTAssertTrue(fd >= 0, @"");
    bool result = bsg_ksfuwriteFmtToFD(fd, "test test testing %d %.1f %s", 1, 2.0f, "3");
    XCTAssertTrue(result, @"");
    NSString* actual = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    XCTAssertNil(error, @"");
    XCTAssertEqualObjects(actual, expected, @"");
}

- (bool) writeToFD:(int) fd fmt:(char*) fmt, ...
{
    va_list args;
    va_start(args, fmt);
    bool result = bsg_ksfuwriteFmtArgsToFD(fd, fmt, args);
    va_end(args);
    return result;
}

- (void) testWriteFmtArgsToFD
{
    NSError* error = nil;
    NSString* path = [self.tempPath stringByAppendingPathComponent:@"test.txt"];
    NSString* expected = @"test test testing 1 2.0 3";

    int fd = open([path UTF8String], O_RDWR | O_CREAT | O_EXCL, 0644);
    XCTAssertTrue(fd >= 0, @"");
    bool result = [self writeToFD:fd fmt: "test test testing %d %.1f %s", 1, 2.0f, "3"];
    XCTAssertTrue(result, @"");
    NSString* actual = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    XCTAssertNil(error, @"");
    XCTAssertEqualObjects(actual, expected, @"");
}

- (void) testReadLineFromFD
{
    NSError* error = nil;
    NSString* path = [self.tempPath stringByAppendingPathComponent:@"test.txt"];
    NSString* source = @"line 1\nline 2\nline 3";
    NSString* expected1 = @"line 1";
    NSString* expected2 = @"line 2";
    NSString* expected3 = @"line 3";
    [source writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    XCTAssertNil(error, @"");

    int fd = open([path UTF8String], O_RDONLY);
    XCTAssertTrue(fd >= 0, @"");
    NSMutableData* data = [NSMutableData dataWithLength:100];
    ssize_t bytesRead;
    NSString* actual;

    bytesRead = bsg_ksfureadLineFromFD(fd, [data mutableBytes], 100);
    XCTAssertTrue(bytesRead > 0, @"");
    actual = [[NSString alloc] initWithBytes:[data bytes]
                                      length:(NSUInteger)bytesRead
                                    encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(actual, expected1, @"");

    bytesRead = bsg_ksfureadLineFromFD(fd, [data mutableBytes], 100);
    XCTAssertTrue(bytesRead > 0, @"");
    actual = [[NSString alloc] initWithBytes:[data bytes]
                                      length:(NSUInteger)bytesRead
                                    encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(actual, expected2, @"");

    bytesRead = bsg_ksfureadLineFromFD(fd, [data mutableBytes], 100);
    XCTAssertTrue(bytesRead > 0, @"");
    actual = [[NSString alloc] initWithBytes:[data bytes]
                                      length:(NSUInteger)bytesRead
                                    encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(actual, expected3, @"");

    bytesRead = bsg_ksfureadLineFromFD(fd, [data mutableBytes], 100);
    XCTAssertTrue(bytesRead == 0, @"");
}

@end

