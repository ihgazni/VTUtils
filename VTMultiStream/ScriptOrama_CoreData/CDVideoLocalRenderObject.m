//
//  CDVideoLocalRenderObject.m
//  UView
//
//  Created by dli on 5/1/16.
//  Copyright © 2016 YesView. All rights reserved.
//

#import "CDVideoLocalRenderObject.h"
#import "CDVideoObject.h"
#import "CDVideoOverlayObject.h"

@implementation CDVideoLocalRenderObject

// Insert code here to add functionality to your managed object subclass

-(void)removeSelfWithAllRelationshipsIfLonely
{
    if ((self.temporary == [NSNumber numberWithBool:YES])&&(([self.parentHashID longLongValue]==0)||(self.parentHashID==NULL))) {
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            
            [self.videoOverlay MR_deleteEntityInContext:localContext];
            [self MR_deleteEntityInContext:localContext];
            
            
        }];
        
    }
}

- (void)forceRemoveIfNoParent
{
    
    if (([self.parentHashID longLongValue]==0)) {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            
            [self.videoOverlay MR_deleteEntityInContext:localContext];
            [self MR_deleteEntityInContext:localContext];
            
            
        }];
        
    } else {
    }
    
}

- (void)forceRemoveIgnoreParent
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        
        [self.videoOverlay MR_deleteEntityInContext:localContext];
        [self MR_deleteEntityInContext:localContext];
        
        
    }];
}








@end


void deleteAllTemporaryCDVideoLocalRenderObjects()
{
    
    
    NSArray * tempCDVideoLocalRenderObjects = [CDVideoLocalRenderObject MR_findByAttribute:@"temporary" withValue:[NSNumber numberWithBool:YES]];
    for (int i = 0 ; i<tempCDVideoLocalRenderObjects.count; i++) {
        CDVideoLocalRenderObject * obj = (CDVideoLocalRenderObject *)tempCDVideoLocalRenderObjects[i];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [obj MR_deleteEntityInContext:localContext];
            
        }];
    }
}



void deleteAllNonTempCDVideoLocalRenderObjects()
{
    
    
    NSArray * tempCDVideoLocalRenderObjects = [CDVideoLocalRenderObject MR_findByAttribute:@"temporary" withValue:[NSNumber numberWithBool:NO]];
    for (int i = 0 ; i<tempCDVideoLocalRenderObjects.count; i++) {
        CDVideoLocalRenderObject * obj = (CDVideoLocalRenderObject *)tempCDVideoLocalRenderObjects[i];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [obj MR_deleteEntityInContext:localContext];
            
        }];
    }
}


void deleteAllCDVideoLocalRenderObjects()
{
    NSArray * tempCDVideoLocalRenderObjects = [CDVideoLocalRenderObject MR_findAll];
    for (int i = 0 ; i<tempCDVideoLocalRenderObjects.count; i++) {
        CDVideoLocalRenderObject * obj = (CDVideoLocalRenderObject *)tempCDVideoLocalRenderObjects[i];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            [obj MR_deleteEntityInContext:localContext];
            
        }];
    }
}


void CDVideoLocalRenderObjectNullifyExceptRelationShip(CDVideoLocalRenderObject * _Nonnull  vlrobj,BOOL temporary)
{
    vlrobj.cropPositionOnOriginalMaterialX = nil;
    vlrobj.cropPositionOnOriginalMaterialY = nil;
    vlrobj.cropSizeX = nil;
    vlrobj.cropSizeY = nil;
    vlrobj.duration = nil;
    vlrobj.filter = nil;
    vlrobj.origAudioWorkDirURLstring = nil;
    vlrobj.origThumbnailURLstring = nil;
    vlrobj.origURLstring = nil;
    vlrobj.origVideoWorkDirURLstring = nil;
    vlrobj.parentHashID = nil;
    vlrobj.postCuttingAudioWorkDirURLstring = nil;
    vlrobj.postCuttingThumbnailURLstring = nil;
    vlrobj.postCuttingURLstring = nil;
    vlrobj.postCuttingVideoWorkDirURLstring = nil;
    vlrobj.postFilteringAudioWorkDirURLstring = nil;
    vlrobj.postFilteringThumbnailURLstring = nil;
    vlrobj.postFilteringURLstring = nil;
    vlrobj.postFilteringVideoWorkDirURLstring = nil;
    vlrobj.postRenderSizeX = nil;
    vlrobj.postRenderSizeY = nil;
    vlrobj.postRenderTempSavingURLstring = nil;
    vlrobj.savePostCutting = nil;
    vlrobj.savePostFiltering = nil;
    vlrobj.startTime = nil;
    vlrobj.temporary = [NSNumber numberWithBool:temporary];
    vlrobj.timeStampInScene = nil;
    vlrobj.origFromAlbumURLstring = nil;
    vlrobj.origFromAlbumAudioWorkDirURLstring = nil;
    vlrobj.origFromAlbumVideoWorkDirURLstring = nil;

}
