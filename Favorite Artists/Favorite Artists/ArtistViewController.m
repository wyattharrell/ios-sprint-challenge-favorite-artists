//
//  ArtistViewController.m
//  Favorite Artists
//
//  Created by Wyatt Harrell on 5/15/20.
//  Copyright © 2020 Wyatt Harrell. All rights reserved.
//

#import "ArtistViewController.h"
#import "WAHArtistController.h"
#import "WAHArtist.h"
#import "WAHArtist+NSJSONSerialization.h"

@interface ArtistViewController ()<UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *yearFormedLabel;
@property (strong, nonatomic) IBOutlet UITextView *biographyTextView;

@property (nonatomic) WAHArtist *artist;

@end

@implementation ArtistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchBar.delegate = self;
}

- (void)updateViews {
    self.nameLabel.hidden = NO;
    self.yearFormedLabel.hidden = NO;
    self.biographyTextView.hidden = NO;
    
    self.nameLabel.text = self.artist.artist;

    if (self.artist.yearFormed == 0) {
        self.yearFormedLabel.text = @"N/A";
    } else {
        self.yearFormedLabel.text = [NSString stringWithFormat:@"Formed in %d", self.artist.yearFormed];
    }
    self.biographyTextView.text = self.artist.biography;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.artistController fetchArtistWithName:searchBar.text completionBlock:^(WAHArtist * _Nullable artist, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Fetching Error: %@", error);
            return;
        }
        
        NSLog(@"Fetched artist: %@", artist);
        self.artist = artist;
        
        // __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateViews];
        });
    }];
}

- (IBAction)saveButtonTapped:(UIBarButtonItem *)sender {
    
    if (self.artist == nil) {
        return;
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject: [self.artist toDictionary] options:0 error:nil];
    NSURL *directory = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    NSURL *url = [[directory URLByAppendingPathComponent:self.artist.artist] URLByAppendingPathExtension: @"json"];
    
    NSLog(@"DIRECTORY: %@", directory);
    NSLog(@"URL: %@", url);

    [data writeToURL:url atomically:YES];
}


@end