//
//  JKLABViewController.m
//  iRequest
//
//  Created by admin on 21/7/14.
//  Copyright (c) 2014 jklab. All rights reserved.
//

#import "JKLABViewController.h"
#import "PromiseKit.h"
#import "PromiseKit+Foundation.h"
#import "OMGHTTPURLRQ.h"
#import "UIImage+fixOrientation.h"

@interface JKLABViewController ()
@property (weak, nonatomic) IBOutlet UITextField *uiUrlToSubmitToTextField;
@property (weak, nonatomic) IBOutlet UITextField *uiImageParameterNameTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *uiCameraBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *uiFindFromGalleryBarButtonItem;
@property (weak, nonatomic) IBOutlet UIImageView *uiUploadedImageImageView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *uiImageFormatSegmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *uiJpgCompressionQualityLabel;
@property (weak, nonatomic) IBOutlet UISlider *uiJpgCompressionQualitySlider;
@property (weak, nonatomic) IBOutlet UIView *uiJpgImageConfigPanelView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintJpgImageConfigPanelViewHeight;
@end

@implementation JKLABViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Synchronize UI with default value
    [self updateCompressionQualityLabel];
    
    // Observe controls' values to later update ui correspondingly
    [self.uiImageFormatSegmentedControl addObserver:self forKeyPath:@"selectedSegmentIndex" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Helpers

- (void)uploadImage:(UIImage *)image
{
    
    NSString *urlToSubmitImageTo, *parameterNameForImage;
    UIImage *imageWithoutExifFlag;
    NSData *imageData;
    
    urlToSubmitImageTo = self.uiUrlToSubmitToTextField.text;
    parameterNameForImage = self.uiImageParameterNameTextField.text;
    
    imageWithoutExifFlag = [image fixOrientation];
    
    switch (self.uiImageFormatSegmentedControl.selectedSegmentIndex) {
        case 0:{
            // PNG
            imageData = UIImagePNGRepresentation(imageWithoutExifFlag);
            break;
        }
        case 1:{
            //JPG
            CGFloat compressionQuality;
            compressionQuality = self.uiJpgCompressionQualitySlider.value;
            imageData = UIImageJPEGRepresentation(imageWithoutExifFlag, compressionQuality);
            break;
        }
    }
    
    NSMutableURLRequest *req = [OMGHTTPURLRQ POST:urlToSubmitImageTo multipartForm:^(void (^addFile)(NSData *, NSString *name, NSString *filename)){
        
        NSString *timestamp, *filenameWithTimestamp;
        NSDateFormatter *dateFormatter;
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        timestamp = [dateFormatter stringFromDate:[NSDate date]];
        filenameWithTimestamp = [NSString stringWithFormat:@"IMAGE %@.png", timestamp];
        
        addFile(imageData, parameterNameForImage, filenameWithTimestamp);
        
    }];
    
    [NSURLConnection promise:req].then(^{
        
        self.uiUploadedImageImageView.image = image;
        
        UIAlertView *uploadSuccessAlert=[[UIAlertView alloc] initWithTitle:@"Photo upload success!" message:@"Successfully sent your image" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [uploadSuccessAlert show];
        
    }).catch(^(NSError *error){
        
        NSLog(@"%@", error);
        
    });
   

}

- (void) updateCompressionQualityLabel
{
    NSString *compressionQuality;
    
    compressionQuality = [NSString stringWithFormat:@"%.03f", self.uiJpgCompressionQualitySlider.value];
    self.uiJpgCompressionQualityLabel.text = compressionQuality;
}


// Binding

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.uiImageFormatSegmentedControl) {
        
        switch (self.uiImageFormatSegmentedControl.selectedSegmentIndex) {
                
            case 0:
                //PNG
                [self.uiJpgImageConfigPanelView setHidden:YES];
                self.constraintJpgImageConfigPanelViewHeight.constant = 0;
                break;
                
            case 1:
                //JPG
                [self.uiJpgImageConfigPanelView setHidden:NO];
                self.constraintJpgImageConfigPanelViewHeight.constant = 53;
                break;
                
        }
        
    }
}


// Non-UI Event Handlers

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image;
    
    image = [info valueForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"%@", image);
    
    [self uploadImage:image];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


// UI Event Handlers
- (IBAction)actionUpdateCompressionQualityLabel:(id)sender {
    [self updateCompressionQualityLabel];
}

- (IBAction)actionHideSoftKeyboard:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)actionGetImageFromCameraAndUpload:(id)sender
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.delegate = self;
    
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (IBAction)actionGetImageFromGalleryAndUpload:(id)sender
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

@end
