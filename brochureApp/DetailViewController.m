//
//  DetailViewController.m
//  brochureApp
//
//  Created by Xiaohe Hu on 5/20/15.
//  Copyright (c) 2015 Xiaohe Hu. All rights reserved.
//

#import "DetailViewController.h"
#import "embEmailData.h"
#import <MessageUI/MessageUI.h>
#import "XHGalleryViewController.h"
@interface DetailViewController () <MFMailComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, XHGalleryDelegate>

{
    NSArray                     *arr_rawData;
}

@property (weak, nonatomic) IBOutlet UIButton *uib_backBtn;
@property (nonatomic, strong) embEmailData                  *emailData;
@property (nonatomic, strong)   XHGalleryViewController *gallery;
@end

@implementation DetailViewController
@synthesize sectionNum, rowNum;

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareGalleryData];
    // Do any additional setup after loading the view.
}
/*
 * Read data from parent ViewController (sectionIndex & rowIndex)
 */
- (void)viewWillAppear:(BOOL)animated
{
    _uil_title.text = [NSString stringWithFormat:@"Section %i row %i", sectionNum+1, rowNum+1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action of buttons

- (IBAction)tapOnBackBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
 * Read gallery data from plist
 */
- (void)prepareGalleryData
{
    NSString *url = [[NSBundle mainBundle] pathForResource:@"photoData" ofType:@"plist"];
    arr_rawData = [[NSArray alloc] initWithContentsOfFile:url];
}

/*
 * Load gallery's view
 */
- (IBAction)tapGalleryBtn:(id)sender {
    _gallery = [[XHGalleryViewController alloc] init];
    _gallery.delegate = self;
    _gallery.startIndex = 0;
    _gallery.view.frame = self.view.bounds;
    _gallery.arr_rawData = [arr_rawData objectAtIndex:0];
//    [self addChildViewController:_gallery];
//    [self.view addSubview: _gallery.view];
    [self.navigationController pushViewController:_gallery animated:YES];
}
/*
 * Gallery delegate method (Remove gallery's view)
 */
- (void)didRemoveFromSuperView
{
 /*
  * Gallery is removed from Navigation controller
  * Delegate method doesn't need to do anything
  */
}

/*
 * Tap on the summery button
 * The action is defined in storyboard
 */
- (IBAction)showSummary:(id)sender {
    
}

/*
 * Tap the share(email) button
 * Currenly all data for email is empty
 */
- (IBAction)tapShareBtn:(id)sender {
    _emailData = [[embEmailData alloc] init];
    _emailData.to = nil;
    _emailData.subject = nil;
    _emailData.body = nil;//kMAILBODY;
    [self prepareEmailData];
}

#pragma mark - Email Delegates
-(void)prepareEmailData
{
    if ([MFMailComposeViewController canSendMail] == YES) {
        
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self; // &lt;- very important step if you want feedbacks on what the user did with your email sheet
        
        if(_emailData.to)
            [picker setToRecipients:_emailData.to];
        
        if(_emailData.cc)
            [picker setCcRecipients:_emailData.cc];
        
        if(_emailData.bcc)
            [picker setBccRecipients:_emailData.bcc];
        
        if(_emailData.subject)
            [picker setSubject:_emailData.subject];
        
        if(_emailData.body)
            [picker setMessageBody:_emailData.body isHTML:YES]; // depends. Mostly YES, unless you want to send it as plain text (boring)
        
        
        // attachment code
        if(_emailData.attachment) {
            
            NSLog(@"_receivedData.attachment");
            
            NSString	*filePath;
            NSString	*justFileName;
            NSData		*myData;
            UIImage		*pngImage;
            NSString	*newname;
            //			if (kshowNSLogBOOL) NSLog(@"%@",_receivedData.attachment);
            
            for (id file in _emailData.attachment)
            {
                
                // check if it is a uiimage and handle
                if ([file isKindOfClass:[UIImage class]]) {
                    
                    myData = UIImagePNGRepresentation(file);
                    [picker addAttachmentData:myData mimeType:@"image/png" fileName:@"image.png"];
                    
                    // might be nsdata for pdf
                } else if ([file isKindOfClass:[NSData class]]) {
                    NSLog(@"pdf");
                    myData = [NSData dataWithData:file];
                    NSString *mimeType;
                    mimeType = @"application/pdf";
                    newname = @"Brochure.pdf";
                    [picker addAttachmentData:myData mimeType:mimeType fileName:newname];
                    
                    // it must be another file type?
                } else {
                    
                    justFileName = [[file lastPathComponent] stringByDeletingPathExtension];
                    
                    NSString *mimeType;
                    // Determine the MIME type
                    if ([[file pathExtension] isEqualToString:@"jpg"]) {
                        mimeType = @"image/jpeg";
                    } else if ([[file pathExtension] isEqualToString:@"png"]) {
                        mimeType = @"image/png";
                        pngImage = [UIImage imageNamed:file];
                    } else if ([[file pathExtension] isEqualToString:@"doc"]) {
                        mimeType = @"application/msword";
                    } else if ([[file pathExtension] isEqualToString:@"ppt"]) {
                        mimeType = @"application/vnd.ms-powerpoint";
                    } else if ([[file pathExtension] isEqualToString:@"html"]) {
                        mimeType = @"text/html";
                    } else if ([[file pathExtension] isEqualToString:@"pdf"]) {
                        mimeType = @"application/pdf";
                    } else if ([[file pathExtension] isEqualToString:@"com"]) {
                        mimeType = @"text/plain";
                    }
                    
                    filePath= [[NSBundle mainBundle] pathForResource:justFileName ofType:[file pathExtension]];
                    
                    if (![[file pathExtension] isEqualToString:@"png"]) {
                        myData = [NSData dataWithContentsOfFile:filePath];
                        myData = [NSData dataWithContentsOfFile:filePath];
                    } else {
                        myData = UIImagePNGRepresentation(pngImage);
                    }
                    [picker addAttachmentData:myData mimeType:mimeType fileName:file];
                }
            }
        }
        
        picker.navigationBar.barStyle = UIBarStyleBlack; // choose your style, unfortunately, Translucent colors behave quirky.
        [self presentViewController:picker animated:YES completion:nil];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status" message:[NSString stringWithFormat:@"Email needs to be configured before this device can send email."]
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thank you!" message:@"Email Sent Successfully"
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
            break;
        case MFMailComposeResultFailed:
            break;
            
        default:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status" message:@"Sending Failed - Unknown Error"
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    NSLog(@"FINISHED");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
