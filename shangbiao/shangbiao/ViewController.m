//
//  ViewController.m
//  shangbiao
//
//  Created by 甘世仁 on 2019/12/10.
//  Copyright © 2019 甘世仁. All rights reserved.
//


#import "ViewController.h"
#import "UIView+Layout.h"
#import "MBProgressHUD/MBProgressHUD.h"

@interface ViewController ()

@property (nonatomic, strong) UIView *shangbiaoBgView;
@property (nonatomic, strong) UILabel *shangbiaoTextLabel;

@property (nonatomic, strong) UIView *backView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    
}

- (void)initViews {
    self.title = @"商标生成器";
    CGFloat topSpace = IsiPhoneX ? 88 : 64;

    self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, topSpace, SCREEN_WIDTH, SCREEN_HEIGHT - topSpace)];
    self.backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.backView];
    
    // 输入商标名字
    
    UILabel *shangbiaoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 104, 40)];
    shangbiaoLabel.textAlignment = NSTextAlignmentCenter;
    shangbiaoLabel.font = [UIFont systemFontOfSize:16];
    shangbiaoLabel.textColor = [UIColor whiteColor];
    shangbiaoLabel.backgroundColor = [UIColor colorWithRed:1/255.0 green:163/255.0 blue:254/255.0 alpha:1.0];
    shangbiaoLabel.layer.cornerRadius = 20;
    shangbiaoLabel.layer.masksToBounds = YES;
    shangbiaoLabel.text = @"输入商标";
    [self.backView addSubview:shangbiaoLabel];
    shangbiaoLabel.center = CGPointMake(SCREEN_WIDTH/2.0 - shangbiaoLabel.frame.size.width/2.0 - 30 , self.backView.frame.size.height -  shangbiaoLabel.frame.size.height * 2);
    shangbiaoLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enterContent)];
    [shangbiaoLabel addGestureRecognizer:tap];
    
    // 下载图片
    UILabel *downloadLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 104, 40)];
    downloadLabel.textAlignment = NSTextAlignmentCenter;
    downloadLabel.font = [UIFont systemFontOfSize:16];
    downloadLabel.textColor = [UIColor whiteColor];
    downloadLabel.backgroundColor = [UIColor colorWithRed:1/255.0 green:163/255.0 blue:254/255.0 alpha:1.0];
    downloadLabel.layer.cornerRadius = 20;
    downloadLabel.layer.masksToBounds = YES;
    downloadLabel.text = @"下载图片";
    [self.backView addSubview:downloadLabel];
    downloadLabel.center = CGPointMake(SCREEN_WIDTH/2.0 + downloadLabel.frame.size.width/2.0 + 30 , self.backView.frame.size.height -  downloadLabel.frame.size.height * 2);
    downloadLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(downloadImage)];
    [downloadLabel addGestureRecognizer:tap2];
    
    // 设置商标相关
    [self initShangbiaoView];
    
}

- (void)downloadImage {
    
    WEAKSELF
    //----每次都会走进来
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            
            NSLog(@"----------Authorized---------");
            
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                //判断是否可以访问
                return;
            }
            [weakSelf save];
            
            
        } else {
            
            NSLog(@"--------Denied or Restricted-------");
            //----为什么没有在这个里面进行权限判断，因为会项目会蹦。。。
        }
    }];
    
    
}

- (void)save {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *image = [self.shangbiaoBgView imageWithView];
        
        if (image) {
            
            [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            WEAKSELF
            [self saveImageToAlbumWithImage:image successCallBack:^(PHAsset *saveAsset) {
                [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:NO];
                
                MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];;
                
                hud.mode = MBProgressHUDModeText;
                hud.detailsLabelText = @"保存成功";
                hud.margin = 10.f;
                hud.removeFromSuperViewOnHide = YES;
                [hud hide:YES afterDelay:1];
                
            } failedCallBack:^{
                
            }];
        }
    });
    
}

/**
 * 保存图片到相册
 */
- (void)saveImageToAlbumWithImage:(UIImage *)image successCallBack:(SaveSuccessCallback)callBack failedCallBack:(SaveFailedCallBack)failedCallBack{
    
    // 判断授权状态
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status != PHAuthorizationStatusAuthorized) return;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *error = nil;
            
            // 保存相片到相机胶卷
            __block PHObjectPlaceholder *createdAsset = nil;
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                createdAsset = [PHAssetCreationRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset;
            } error:&error];
            
            if (error) {
                if (failedCallBack) {
                    failedCallBack();
                }
                //                NSLog(@"保存失败：%@", error);
                return;
            }
            
            // 拿到自定义的相册对象
            PHAssetCollection *collection = [self collection];
            if (collection == nil) return;
            
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection] insertAssets:@[createdAsset] atIndexes:[NSIndexSet indexSetWithIndex:0]];
            } error:&error];
            
            if (error) {
                //                NSLog(@"保存失败：%@", error);
            } else {
                
                PHFetchResult<PHAsset *> *assetResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
                PHAsset * saveAsset = [assetResult firstObject];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callBack) {
                        callBack(saveAsset);
                    }
                });
                
                //                NSLog(@"保存成功%@",[NSThread currentThread]);
            }
        });
    }];
}

/**
 * 获得自定义的相册对象
 */
- (PHAssetCollection *)collection
{
    // 先从已存在相册中找到自定义相册对象
    PHFetchResult<PHAssetCollection *> *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collectionResult) {
        if ([collection.localizedTitle isEqualToString:DMCollectionName]) {
            return collection;
        }
    }
    
    // 新建自定义相册
    __block NSString *collectionId = nil;
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        collectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:DMCollectionName].placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    
    if (error) {
        //        NSLog(@"获取相册【%@】失败", DMCollectionName);
        return nil;
    }
    
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionId] options:nil].lastObject;
}

- (void)enterContent {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"设置商标名称" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入名称";
    }];
    
    WEAKSELF
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [cancelAction setValue:[UIColor grayColor] forKey:@"titleTextColor"];
    
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UITextField *temp = alert.textFields.firstObject;
        
        weakSelf.shangbiaoTextLabel.text = temp.text;
        
        
    }];
    [confirmAction setValue:[UIColor colorWithRed:1/255.0 green:163/255.0 blue:254/255.0 alpha:1.0] forKey:@"titleTextColor"];
    
    [alert addAction:confirmAction];
    [alert addAction:cancelAction];
    alert.popoverPresentationController.sourceView = ALERTVC_SOURCEVIEW;
    alert.popoverPresentationController.sourceRect = ALERTVC_SOURCERECT;
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)initShangbiaoView {
    CGFloat width = 400;
    self.shangbiaoBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    self.shangbiaoBgView.backgroundColor = [UIColor whiteColor];
    [self.backView addSubview:self.shangbiaoBgView];
    self.shangbiaoBgView.center = CGPointMake(SCREEN_WIDTH/2.0, self.backView.frame.size.height/2.0 - 100);
    [self addShadowToView:self.shangbiaoBgView withColor:[UIColor blackColor]];
    
    self.shangbiaoTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 80)];
    self.shangbiaoTextLabel.textAlignment = NSTextAlignmentCenter;
    self.shangbiaoTextLabel.font = [UIFont boldSystemFontOfSize:32];
    self.shangbiaoTextLabel.textColor = [UIColor blackColor];
    [self.shangbiaoBgView addSubview:self.shangbiaoTextLabel];
    self.shangbiaoTextLabel.center = CGPointMake(self.shangbiaoBgView.frame.size.width/2.0, self.shangbiaoBgView.frame.size.height/2.0);
    
}

/// 添加四边阴影效果
- (void)addShadowToView:(UIView *)theView withColor:(UIColor *)theColor {
    // 阴影颜色
    theView.layer.shadowColor = theColor.CGColor;
    // 阴影偏移，默认(0, -3)
    theView.layer.shadowOffset = CGSizeMake(0,0);
    // 阴影透明度，默认0
    theView.layer.shadowOpacity = 0.5;
    // 阴影半径，默认3
    theView.layer.shadowRadius = 5;
}

@end
