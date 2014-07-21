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

@interface JKLABViewController ()
@property (weak, nonatomic) IBOutlet UITextField *uiUrlToSubmitToTextField;
@property (weak, nonatomic) IBOutlet UITextField *uiImageParameterNameTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *uiCameraBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *uiFindFromGalleryBarButtonItem;
@property (weak, nonatomic) IBOutlet UIImageView *uiUploadedImageImageView;
@end

@implementation JKLABViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Helpers

- (void)uploadImage:(UIImage *)image
{
    
    NSData *imageData;
    NSString *urlToSubmitImageTo, *parameterNameForImage;
    
    urlToSubmitImageTo = self.uiUrlToSubmitToTextField.text;
    parameterNameForImage = self.uiImageParameterNameTextField.text;
    
    imageData = UIImagePNGRepresentation(image);
    
    NSMutableURLRequest *req = [OMGHTTPURLRQ POST:urlToSubmitImageTo multipartForm:^(void (^addFile)(NSData *, NSString *name, NSString *filename)){
        
        NSString *timestamp, *filenameWithTimestamp;
        NSDateFormatter *dateFormatter;
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        timestamp = [dateFormatter stringFromDate:[NSDate date]];
        filenameWithTimestamp = [NSString stringWithFormat:@"IMAGE %@", timestamp];
        
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
