//
//  test4Tests.m
//  test4Tests
//
//  Created by yuliyang on 2021/11/29.
//  Copyright © 2021 yuliyang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AWSS3.h>

@interface test4Tests : XCTestCase

@end

@implementation test4Tests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testCreateBucket {
    NSString *endpoint = @"http://127.0.0.1:8080";
    NSString *access_key = @"yly";
    NSString *secret_key = @"yly";
    AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc]
            initWithAccessKey:access_key
                    secretKey:secret_key];
    AWSEndpoint *customEndpoint = [[AWSEndpoint alloc] initWithURLString:endpoint];
    AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc]
            initWithRegion:AWSRegionUSEast1
                  endpoint:customEndpoint
       credentialsProvider:credentialsProvider];
    [AWSS3 registerS3WithConfiguration:serviceConfiguration forKey:@"customendpoint"];
    AWSS3 *s3 = [AWSS3 S3ForKey:@"customendpoint"];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = serviceConfiguration;

    AWSS3CreateBucketRequest *createBucketReq = [AWSS3CreateBucketRequest new];
    createBucketReq.bucket = @"iostest2";
//    AWSS3CreateBucketConfiguration *createBucketConfiguration = [AWSS3CreateBucketConfiguration new];
//    createBucketConfiguration.locationConstraint = AWSS3BucketLocationConstraintCNBeijing1;
//    createBucketReq.createBucketConfiguration = createBucketConfiguration;
//createBucketReq.ACL = AWSS3BucketCannedACLPublicRead; #设置桶为公开可读
    [[[s3 createBucket:createBucketReq] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"failed");
        } else {
            NSLog(@"success");
        }
        return nil;
    }] waitUntilFinished];
}

- (void)testDelBucket {
    NSString *endpoint = @"http://127.0.0.1:8080";
    NSString *access_key = @"yly";
    NSString *secret_key = @"yly";
    AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc]
            initWithAccessKey:access_key
                    secretKey:secret_key];
    AWSEndpoint *customEndpoint = [[AWSEndpoint alloc] initWithURLString:endpoint];
    AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc]
            initWithRegion:AWSRegionUSEast1
                  endpoint:customEndpoint
       credentialsProvider:credentialsProvider];
    [AWSS3 registerS3WithConfiguration:serviceConfiguration forKey:@"customendpoint"];
    AWSS3 *s3 = [AWSS3 S3ForKey:@"customendpoint"];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = serviceConfiguration;

    AWSS3DeleteBucketRequest *request = [AWSS3DeleteBucketRequest alloc];
    request.bucket = @"iostest2";
    [[[s3 deleteBucket:request] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"failed");
        } else {
            NSLog(@"success");
        }
        return nil;
    }] waitUntilFinished];
}

- (void)testPutobj {
    [AWSDDLog sharedInstance].logLevel = AWSDDLogLevelAll;
    [AWSDDLog addLogger:[AWSDDTTYLogger sharedInstance]];
    NSString *endpoint = @"http://127.0.0.1:8080";
    NSString *access_key = @"yly";
    NSString *secret_key = @"yly";
    AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc]
            initWithAccessKey:access_key
                    secretKey:secret_key];
    AWSEndpoint *customEndpoint = [[AWSEndpoint alloc] initWithURLString:endpoint];
    AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc]
            initWithRegion:AWSRegionUSEast1
                  endpoint:customEndpoint
       credentialsProvider:credentialsProvider];
    serviceConfiguration.maxRetryCount = 0;
    [AWSS3 registerS3WithConfiguration:serviceConfiguration forKey:@"customendpoint"];
    AWSS3 *s3 = [AWSS3 S3ForKey:@"customendpoint"];

    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = serviceConfiguration;

    AWSS3PutObjectRequest *putObjectRequest = [AWSS3PutObjectRequest new];
    putObjectRequest.key = @"11111";
    putObjectRequest.bucket = @"iostest1";
    NSString *testObjectStr = @"a test object string.";
    NSData *testObjectData = [testObjectStr dataUsingEncoding:NSUTF8StringEncoding];
    putObjectRequest.body = testObjectData;
    putObjectRequest.contentLength = [NSNumber numberWithUnsignedInteger:[testObjectData length]];
    [[[s3 putObject:putObjectRequest] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"failed");
        } else {
            NSLog(@"success");
        }
        return nil;
    }] waitUntilFinished];
}

- (void)testPresignedUrl {
    NSString *endpoint = @"http://127.0.0.1:8080";
    NSString *access_key = @"yly";
    NSString *secret_key = @"yly";
    AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc]
            initWithAccessKey:access_key
                    secretKey:secret_key];
    AWSEndpoint *customEndpoint = [[AWSEndpoint alloc] initWithURLString:endpoint];
    AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc]
            initWithRegion:AWSRegionUSEast1
                  endpoint:customEndpoint
       credentialsProvider:credentialsProvider];
    [AWSS3 registerS3WithConfiguration:serviceConfiguration forKey:@"customendpoint"];
    AWSS3 *s3 = [AWSS3 S3ForKey:@"customendpoint"];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = serviceConfiguration;

    AWSS3GetPreSignedURLRequest *request = [AWSS3GetPreSignedURLRequest alloc];
    request.bucket = @"ylyb1";
    request.key = @"1";
    request.HTTPMethod = AWSHTTPMethodGET;
    request.expires = [NSDate dateWithTimeIntervalSinceNow:60 * 60];
    [[[AWSS3PreSignedURLBuilder defaultS3PreSignedURLBuilder] getPreSignedURL:request]
            continueWithBlock:^id(AWSTask *task) {
                if (task.error) {
                    NSLog(@"Error: %@", task.error);
                } else {
                    NSURL *presignedURL = task.result;
                    NSLog(@"%@", presignedURL);
                }
                return nil;
            }];
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
