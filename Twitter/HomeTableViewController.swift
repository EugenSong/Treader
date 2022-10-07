//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by Eugene Song on 9/28/22.
//  Copyright © 2022 Dan. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {

    
    // variables needed to grab tweets using API
    // --------------------------------------------
    // init a dictionary
    var tweetArray = [NSDictionary]()
    var numberOfTweets: Int!
    
    // refresh function
    let myRefreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 15, *) {
            
                // fix to nav barTint issue
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = #colorLiteral(red: 0, green: 0.6821567416, blue: 0.9409773946, alpha: 1)
                navigationController?.navigationBar.standardAppearance = appearance;
                navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
            }
        
        
        myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        
        // this row height is automactically calculated
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.estimatedRowHeight = 130

    }
    
    // call viewDidAppear each time a new View is shown / updated
    override func viewDidAppear(_ animated: Bool) {
        // call superclass
        super.viewDidAppear(animated)
        self.loadTweets()
    }
    
    @objc func loadTweets() {
        
        numberOfTweets = 20
        
        let myUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let myParams = ["count": numberOfTweets]
        
        // pulling the tweet calling api
        TwitterAPICaller.client?.getDictionariesRequest(url: myUrl, parameters: myParams, success: { (tweets: [NSDictionary]) in
            
            self.tweetArray.removeAll()  // empties an array
            
            // filling the array with each tweet
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            
            self.tableView.reloadData()
            self.myRefreshControl.endRefreshing()
            
        }, failure: { (Error) in
            print("Could not retrieve tweet")
        })
    }
    
    func loadMoreTweets() {
        let myUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        
        numberOfTweets = numberOfTweets + 20
        
        let myParams = ["count": numberOfTweets]
        
        // pulling the tweet calling api
        TwitterAPICaller.client?.getDictionariesRequest(url: myUrl, parameters: myParams, success: { (tweets: [NSDictionary]) in
            
            self.tweetArray.removeAll()  // empties an array
            
            // filling the array with each tweet
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            
        }, failure: { (Error) in
            print("Could not retrieve tweet")
        })
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tweetArray.count {
            loadMoreTweets()
        }
    }
    
    
    // make sure to give identifier to TableViewCell and copy over into dequeResuableCell func
    
    // after creating TableViewCell , cast it to the cell below (how to pass data from view to view)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetTableViewCell
        
        
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary
        
        cell.profileNameLabel.text = user["name"] as? String
        cell.profileTweetLabel.text = tweetArray[indexPath.row]["text"] as? String
        
        let imageUrl = URL(string: (user["profile_image_url_https"] as? String)!)
        let data = try? Data(contentsOf: imageUrl!)
        
        if let imageData = data {
            cell.profileImageView.image = UIImage(data: imageData)
        }
        
        // as! b/c we are sure it's a bool
        cell.setFavorited(tweetArray[indexPath.row]["favorited"] as! Bool)
        
        // set tweetid here to use in tweetViewController
        cell.tweetId = tweetArray[indexPath.row]["id"] as! Int
        
        // use method instead of variable
        cell.setRetweeted( tweetArray[indexPath.row]["retweeted"] as! Bool)
            
        return cell
    }
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        // return the # of tweets
        return tweetArray.count
    }

    @IBAction func logOutPressed(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
    }
    
}
