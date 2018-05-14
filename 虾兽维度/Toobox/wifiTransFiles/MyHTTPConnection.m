
#import "MyHTTPConnection.h"
#import "HTTPMessage.h"
#import "HTTPDataResponse.h"
#import "DDNumber.h"
#import "HTTPLogging.h"

#import "MultipartFormDataParser.h"
#import "MultipartMessageHeaderField.h"
#import "HTTPDynamicFileResponse.h"
#import "HTTPFileResponse.h"

#import "XMWifiGroupTool.h"
#import "MBProgressHUD+NK.h"


@interface MyHTTPConnection()

@property (nonatomic, strong)   MBProgressHUD *hud;             // 进度条
@property (nonatomic, strong)   NSString *uploadFileName;       // 当前上传的文件名称
@property (nonatomic, strong)   NSString *haveUploadFiles;      // 已经上传的文件名称
@property (nonatomic, assign)   double uploadFileTotalLength;   // 所有上传文件的总大小
@property (nonatomic, assign)   double uploadFileLength;        // 当前文件已经上传的大小
@property (nonatomic, assign)   double starTime;                // 上传开始时间
@property (nonatomic, assign)   double percent;                 // 进度(百分比)
@property (nonatomic, assign)   BOOL isTimer;                   // 标记是否在计时
@property (nonatomic, assign)   BOOL isTransportSuccess;                   // 标记是否在计时

@end


// Log levels : off, error, warn, info, verbose
// Other flags: trace
static const int httpLogLevel = HTTP_LOG_LEVEL_VERBOSE; // | HTTP_LOG_FLAG_TRACE;


/**
 * All we have to do is override appropriate methods in HTTPConnection.
 **/

@implementation MyHTTPConnection

- (instancetype)init{
    if (self = [super init]){
        self.uploadFileName = @"";
        self.haveUploadFiles = @"";
        self.starTime = 0;
        self.uploadFileTotalLength = 0;
        self.uploadFileLength = 0;
        self.isTimer = NO;
        self.isTransportSuccess = NO;
    }
    return self;
}

- (MBProgressHUD *)hud
{
    if (!_hud)
    {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
        hud.mode = MBProgressHUDModeDeterminate;
        _hud = hud;

    }
    return _hud;
}


- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
	HTTPLogTrace();
	
	// Add support for POST
	
	if ([method isEqualToString:@"POST"])
	{
		if ([path isEqualToString:@"/upload.html"])
		{
			return YES;
		}
	}
	
	return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
	HTTPLogTrace();
	
	// Inform HTTP server that we expect a body to accompany a POST request
	
	if([method isEqualToString:@"POST"] && [path isEqualToString:@"/upload.html"]) {
        // here we need to make sure, boundary is set in header
        // 获得请求头的信息,文件大小
        NSString* contentType = [request headerField:@"Content-Type"];
        NSString *contentLength = [request headerField:@"Content-Length"];
        self.uploadFileTotalLength = [contentLength doubleValue];
        NSUInteger paramsSeparator = [contentType rangeOfString:@";"].location;
        if( NSNotFound == paramsSeparator ) {
            return NO;
        }
        if( paramsSeparator >= contentType.length - 1 ) {
            return NO;
        }
        NSString* type = [contentType substringToIndex:paramsSeparator];
        if( ![type isEqualToString:@"multipart/form-data"] ) {
            // we expect multipart/form-data content type
            return NO;
        }

		// enumerate all params in content-type, and find boundary there
        NSArray* params = [[contentType substringFromIndex:paramsSeparator + 1] componentsSeparatedByString:@";"];
        for( NSString* param in params ) {
            paramsSeparator = [param rangeOfString:@"="].location;
            if( (NSNotFound == paramsSeparator) || paramsSeparator >= param.length - 1 ) {
                continue;
            }
            NSString* paramName = [param substringWithRange:NSMakeRange(1, paramsSeparator-1)];
            NSString* paramValue = [param substringFromIndex:paramsSeparator+1];
            
            if( [paramName isEqualToString: @"boundary"] ) {
                // let's separate the boundary from content-type, to make it more handy to handle
                [request setHeaderField:@"boundary" value:paramValue];
            }
        }
        // check if boundary specified
        if( nil == [request headerField:@"boundary"] )  {
            return NO;
        }
        return YES;
    }
	return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
	HTTPLogTrace();
	
	if ([method isEqualToString:@"POST"] && [path isEqualToString:@"/upload.html"])
	{

		// this method will generate response with links to uploaded file
		NSMutableString* filesStr = [[NSMutableString alloc] init];

		for( NSString* filePath in uploadedFiles ) {
			//generate links
			[filesStr appendFormat:@"<a href=\"%@\"> %@ </a><br/>",filePath, [filePath lastPathComponent]];
		}
		NSString* templatePath = [[config documentRoot] stringByAppendingPathComponent:@"upload.html"];
		NSDictionary* replacementDict = [NSDictionary dictionaryWithObject:filesStr forKey:@"MyFiles"];
		// use dynamic file response to apply our links to response template
		return [[HTTPDynamicFileResponse alloc] initWithFilePath:templatePath forConnection:self separator:@"%" replacementDictionary:replacementDict];
	}
	if( [method isEqualToString:@"GET"] && [path hasPrefix:@"/upload/"] ) {
		// let download the uploaded files
		return [[HTTPFileResponse alloc] initWithFilePath: [[config documentRoot] stringByAppendingString:path] forConnection:self];
	}
	
	return [super httpResponseForMethod:method URI:path];
}

- (void)prepareForBodyWithSize:(UInt64)contentLength
{
	HTTPLogTrace();
	
	// set up mime parser
    NSString* boundary = [request headerField:@"boundary"];
    parser = [[MultipartFormDataParser alloc] initWithBoundary:boundary formEncoding:NSUTF8StringEncoding];
    parser.delegate = self;

	uploadedFiles = [[NSMutableArray alloc] init];
}

- (void)processBodyData:(NSData *)postDataChunk
{
	HTTPLogTrace();
    // append data to the parser. It will invoke callbacks to let us handle
    // parsed data.
    [parser appendData:postDataChunk];
}


//-----------------------------------------------------------------
#pragma mark multipart form data parser delegate(上传过程的回调)

/// 开始上传
- (void) processStartOfPartWithHeader:(MultipartMessageHeader*) header {
	// in this sample, we are not interested in parts, other then file parts.
	// check content disposition to find out filename

    MultipartMessageHeaderField* disposition = [header.fields objectForKey:@"Content-Disposition"];
	NSString* filename = [[disposition.params objectForKey:@"filename"] lastPathComponent];

    if ( (nil == filename) || [filename isEqualToString: @""] ) {
        // it's either not a file part, or
		// an empty form sent. we won't handle it.
		return;
	}
//	NSString* uploadDirPath = [[config documentRoot] stringByAppendingPathComponent:@"upload"];

//	BOOL isDir = YES;
//	if (![[NSFileManager defaultManager]fileExistsAtPath:uploadDirPath isDirectory:&isDir ]) {
//		[[NSFileManager defaultManager]createDirectoryAtPath:uploadDirPath withIntermediateDirectories:YES attributes:nil error:nil];
//	}
	
    
    // 上传文件保存到的沙盒路径XMWifiUploadDirPath
    
    NSString* filePath = [[XMWifiGroupTool getCurrentGroupPath] stringByAppendingPathComponent:filename];
    if( [[NSFileManager defaultManager] fileExistsAtPath:filePath] ) {
        storeFile = nil;
        double fileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil].fileSize;
        self.uploadFileTotalLength -= fileSize;
        HTTPLogWarn(@"File has exist at %@",filePath);
    }
    else {
		HTTPLogVerbose(@"Saving file to %@", filePath);
		if(![[NSFileManager defaultManager] createDirectoryAtPath:XMWifiUploadDirPath withIntermediateDirectories:true attributes:nil error:nil]) {
			HTTPLogError(@"Could not create directory at path: %@", filePath);
		}
		if(![[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil]) {
			HTTPLogError(@"Could not create file at path: %@", filePath);
		}
        // 初始化上传参数
        self.uploadFileLength = 0;
        self.starTime = [NSDate date].timeIntervalSince1970;
        self.uploadFileName = filename;
		storeFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
		[uploadedFiles addObject: [NSString stringWithFormat:@"/upload/%@", filename]];
        
        HTTPLogInfo(@"star upload file:%@",filename);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.haveUploadFiles.length > 0){
                // 上传非第一个文件
                self.hud.detailsLabel.text = [NSString stringWithFormat:@"%@ 上传中.. 总大小:%.3fM \n%@",self.uploadFileName,self.uploadFileTotalLength /1024.0/ 1024.0,self.haveUploadFiles];
            
            }else{
                // 上传第一个文件
                self.hud.detailsLabel.text = [NSString stringWithFormat:@"%@ 上传中.. 总大小:%.3fM",self.uploadFileName,self.uploadFileTotalLength /1024.0/ 1024.0];
            }
        });
        // 开个异步计时,如果进度条太久没更新就强制隐藏hud
        if (!self.isTimer){
            self.isTimer = YES;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                CGFloat per = 2.0;
                while (per != self.percent) {
                    per = self.percent;
                    sleep(20);
                }
                // 进度条没有进展,而且反馈标志没有,表示卡住了
                if (!self.isTransportSuccess){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.hud hideAnimated:YES];
                        self.hud = nil;
                        NSLog(@"强制结束%s-- %@",__func__,self);
                        self.isTimer = NO;
                    });
                }
            });
        }
    }
}


/// 上传中
- (void) processContent:(NSData*) data WithHeader:(MultipartMessageHeader*) header 
{
	// here we just write the output from parser to the file.
	if( storeFile ) {
		[storeFile writeData:data];
        self.uploadFileLength += data.length;
//        HTTPLogInfo(@"upload progress: %.2f%%",self.uploadFileLength/self.uploadFileTotalLength * 100);
        // 进度条显示
        dispatch_async(dispatch_get_main_queue(), ^{
            self.hud.progress = self.uploadFileLength/self.uploadFileTotalLength;
            self.percent = self.hud.progress;
            self.hud.label.text = [NSString stringWithFormat:@"传输进度:%.2f%%",self.uploadFileLength/self.uploadFileTotalLength * 100];
        });
	}
}

/// 上传完成
- (void) processEndOfPartWithHeader:(MultipartMessageHeader*) header
{
    if (storeFile == nil) return;
	// as the file part is over, we close the file.
	[storeFile closeFile];
	storeFile = nil;
    double useTime = [[NSDate date] timeIntervalSince1970] - self.starTime;
    if(self.uploadFileLength < 1024.0){
        // < 1k
        HTTPLogInfo(@"upload end---file size:%.1f Byte --- time:%.1f 秒",self.uploadFileLength,useTime);
    }else if(self.uploadFileLength < 1024.0 * 1024.0){
        // < 1M
        HTTPLogInfo(@"upload end---file size:%.3fK --- time:%.1f 秒",self.uploadFileLength / 1024.0,useTime);
    }else{
        HTTPLogInfo(@"upload end---file size:%.3fM --- time:%.1f 秒",self.uploadFileLength / 1024.0 /1024.0,useTime);
    }
    // 减去已经上传的文件大小
    self.uploadFileTotalLength -= self.uploadFileLength;
    self.haveUploadFiles = [NSString stringWithFormat:@"%@\n文件:%@ 上传成功",self.haveUploadFiles,self.uploadFileName];
    // 结束进度条,每次上传的大小最大为262144
    dispatch_async(dispatch_get_main_queue(), ^{
        // 所有文件已经上传完毕或者最后一次的262144没有被计算进去也算完成
        if (0 == self.uploadFileTotalLength || 262144 >= self.uploadFileTotalLength){
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            [MBProgressHUD show:@"完成" icon:@"Checkmark.png" view:window];
            
            [self.hud hideAnimated:YES];
            self.hud = nil;
            // 通知外界传输完成
            [[NSNotificationCenter defaultCenter] postNotificationName:@"XMWifiTransfronFilesComplete" object:self.haveUploadFiles];
            self.isTransportSuccess = YES;
        }else{
            // 来到这里表示上传多个文件
            self.hud.detailsLabel.text = self.haveUploadFiles;
        }
    });
    
    
}

- (void) processPreambleData:(NSData*) data 
{
    // if we are interested in preamble data, we could process it here.

}

- (void) processEpilogueData:(NSData*) data 
{
    // if we are interested in epilogue data, we could process it here.

}

@end
