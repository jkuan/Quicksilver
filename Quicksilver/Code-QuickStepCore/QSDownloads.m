//
//  QSDownloads.m
//  Quicksilver
//
//  Created by Rob McBroom on 4/8/11.
//
//  This class should be used to manage anything having to do with
//  the user's Downloads folder.
//

#import "QSDownloads.h"

@implementation QSDownloads
- (id)resolveProxyObject:(id)proxy {
    NSString *downloads = [@"~/Downloads" stringByStandardizingPath];
    NSFileManager *manager = [[NSFileManager alloc] init];
	NSString *downloadPath, *mrdpath;
	NSDate *modified = nil;
    NSDate *mostRecent = [NSDate distantPast];

	NSNumber *isDir;
	NSNumber *isPackage;
	NSURL *downloadsURL = [NSURL URLWithString:downloads];
	// An array of the directory contents, keeping the isDirectory key, attributeModificationDate key and skipping hidden files
	NSArray *contents = [manager contentsOfDirectoryAtURL:downloadsURL
							   includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLIsDirectoryKey,NSURLAttributeModificationDateKey,nil]
												  options:NSDirectoryEnumerationSkipsHiddenFiles
													error:nil];
	for (NSURL *downloadedFile in contents) {
		NSError *err = nil;
		
		NSString *fileExtension = [downloadedFile pathExtension];
		if ([fileExtension isEqualToString:@"download"] ||
			[fileExtension isEqualToString:@"part"] ||
			[fileExtension isEqualToString:@"dtapart"] ||
			[fileExtension isEqualToString:@"crdownload"]) {
			continue;
		}
		
		// Do not show folders
		if ([downloadedFile getResourceValue:&isDir forKey:NSURLIsDirectoryKey error:&err] && [isDir boolValue]) {
			if (err != nil) {
				NSLog(@"Error getting resource value for %@\nError: %@",downloadPath,err);
				continue;
			}
			// Show packages (e.g. .app and .qsplugin packages)
			if ([downloadedFile getResourceValue:&isPackage forKey:NSURLIsPackageKey error:&err] && ![isPackage boolValue]) {
				if (err != nil) {
					NSLog(@"Error getting resource value for %@\nError: %@",downloadPath,err);
				}
				continue;
			}
		}
		downloadPath = [downloadedFile path];
		if([manager fileExistsAtPath:[downloadPath stringByAppendingPathExtension:@"part"]]) {
			continue;
		}
		// compare the modified date of the file with the most recent download file
		[downloadedFile getResourceValue:&modified forKey:NSURLAttributeModificationDateKey error:&err];
		if (err != nil) {
			NSLog(@"Error getting resource value for %@\nError: %@",downloadPath,err);
			continue;
		}
		if ([mostRecent compare:modified] == NSOrderedAscending) {
			mostRecent = modified;
			mrdpath = downloadPath;
		}
	}
	[manager release];
    return [QSObject fileObjectWithPath:mrdpath];
}
@end
