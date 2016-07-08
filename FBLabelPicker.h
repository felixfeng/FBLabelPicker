//
//  FBLabelPicker.h
//  FBLabelPicker
//
//  Created by fengfelix on 15/12/17.
//  Copyright © 2015年 felix. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const FBLabelPickerKeyID;
extern NSString * const FBLabelPickerKeyTitle;

@protocol FBLabelPickerDelegate;

@interface FBLabelPicker : UIView
@property (nonatomic, weak) id<FBLabelPickerDelegate> delegate;
@property (nonatomic, strong) NSArray *selectedAssets;
@property (nonatomic, strong) NSString *placeholder;

- (void)addAsset:(NSDictionary *)asset;
- (void)addAssets:(NSArray *)assets;
- (void)removeAsset:(NSDictionary *)asset;
- (void)removeAssets:(NSArray *)assets;
- (void)clear;
@end

@protocol FBLabelPickerDelegate <NSObject>
- (void)pickerFinished:(FBLabelPicker *)picker;
- (void)picker:(FBLabelPicker *)picker didSelectedAsset:(NSDictionary *)asset;
@end
