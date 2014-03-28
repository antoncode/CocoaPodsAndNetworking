//
//  ViewController.m
//  TwitterTimeline
//
//  Created by Anton Rivera on 3/25/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import "ViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "Tweet.h"

@interface ViewController ()

@property (nonatomic, strong) NSArray *array;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self twitterTimeline];
}

- (void)twitterTimeline
{
    ACAccountStore *account = [[ACAccountStore alloc] init];  // Creates AccountStore object.
    
        // Asks for the Twitter accounts configured on the device.
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [account requestAccessToAccountsWithType:accountType
                                     options:nil
                                  completion:^(BOOL granted, NSError *error)
    {
        // If we have access to Twitter account configured on the device we will contact the Twitter API.
        if (granted == YES) {
            NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType]; // Retrieves an array of Twitter accounts configured on the device.
            // If there is at least one account we will contact the Twitter API.
            if ([arrayOfAccounts count] > 0) {
                ACAccount *twitterAccount = [arrayOfAccounts lastObject]; // Sets the last account on the device to the twitterAccount variable.
                
                NSURL *requestAPI = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/user_timeline.json"]; //API call that returns entries in a user's timeline.
                
                // The requestAPI requires us to tell it how much data to return so we use an NSDictionary to set the 'count'.
                NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
                [parameters setObject:@"100" forKey:@"count"];
                [parameters setObject:@"1" forKey:@"include_entities"];
                
                // This is where we are getting the data using SLRequest.
                SLRequest *posts = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                      requestMethod:SLRequestMethodGET
                                                                URL:requestAPI
                                                         parameters:parameters];
                posts.account = twitterAccount;
                
                // The postRequest: method call now accesses the NSData object returned.
                [posts performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    // THE NSJSONSerialization class is then used to parse the data returned and assign it to our array.
                    self.array = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                    if (self.array.count != 0) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData]; // Here we tell the table view to reload the data it just received.
                        });
                    }
                }];
            }
        } else {
            // Handle failure to get account access
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}


#pragma mark Search

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self twitterTimelineSearch:searchBar.text];
}

- (void)twitterTimelineSearch:(NSString *)queryString
{
    NSOperationQueue *downloadQueue = [NSOperationQueue new];
    [downloadQueue addOperationWithBlock:^{
        
        NSString *searchURLString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/search/tweets.json?q=%@", queryString];
        
        NSURL *searchURL = [NSURL URLWithString:searchURLString];
        
        NSData *searchData = [NSData dataWithContentsOfURL:searchURL];
        
        NSDictionary *searchDict = [NSJSONSerialization JSONObjectWithData:searchData
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:nil];
        
        NSMutableArray *tempTweets = [NSMutableArray new];
        
        for (NSDictionary *tweet in [searchDict objectForKey:@"search_metadata"])
        {
            for (NSDictionary *metadata in [tweet objectForKey:@"query"]) {
                Tweet *downloadedTweet = [[Tweet alloc] initWithJSON:metadata];
                [tempTweets addObject:downloadedTweet];
            }
        }
        
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        
        [mainQueue addOperationWithBlock:^{
            _array = tempTweets;
            [self.tableView reloadData];
        }];
        
    }];

//    NSString *encodedQuery = [queryString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSLog(queryString);
//    
//    ACAccountStore *account = [[ACAccountStore alloc] init];
//    
//    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
//    [account requestAccessToAccountsWithType:accountType
//                                     options:NULL
//                                  completion:^(BOOL granted, NSError *error)
//     {
//         if (granted == YES)
//         {
//             NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
//             if ([arrayOfAccounts count] > 0) {
//                 ACAccount *twitterAccount = [arrayOfAccounts lastObject];
//                 
//                 NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/search/tweets.json?q=%@", queryString]];
//
//                 NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
//                 [parameters setObject:@"10" forKey:@"count"];
//                 [parameters setObject:@"1" forKey:@"entities"];
//                 [parameters setObject:queryString forKey:@"query"];
//                 
//                 SLRequest *slRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
//                                                           requestMethod:SLRequestMethodGET
//                                                                     URL:url
//                                                              parameters:parameters];
//                 slRequest.account = twitterAccount;
//                 
//                 [slRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
//                     self.array = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
//                     if (self.array.count != 0) {
//                         dispatch_async(dispatch_get_main_queue(), ^{
//                             [self.tableView reloadData];
//                         });
//                     }
//                 }];
//             } else {
//                 // Handle failure to get account access
//                 NSLog(@"%@", [error localizedDescription]);
//             }
//         }
//     }];
}


#pragma mark Table View Data Source Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Returns the number of rows for the table view using the array instance variable.
    return [_array count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Creates each cell for the table view.
    static NSString *cellID = @"CELLID";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    // Creates an NSDictionary that holds the user's posts and then loads the data into each cell of the table view.
    NSDictionary *tweet = _array[indexPath.row];
    cell.textLabel.text = tweet[@"text"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // When a user selects a row this will deselect the row.
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
