//
//  ViewController.swift
//  Hydrogen
//
//  Created by Jacob Bashista on 10/23/17.
//  Copyright © 2017 Jacob Bashista. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import ImageIO

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var postsTableView: UITableView!
    
    
    var posts = [Post]()
    
    var curUrl = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        postsTableView.delegate = self;
        postsTableView.dataSource = self;
        
        
        Alamofire.request("https://www.reddit.com/r/all/.json?limit=100").responseJSON { response in
            
            let jsonData = JSON(response.result.value!)
            
            let postsJSON = jsonData["data"]["children"]
            
            for post in postsJSON{
                let title = post.1["data"]["title"].stringValue
                let url = post.1["data"]["url"].stringValue
                let selfText = post.1["data"]["selftext"].stringValue
                let subreddit = post.1["data"]["subreddit"].stringValue
                var rawScore = post.1["data"]["score"].doubleValue
                var rawTime = post.1["data"]["created"].doubleValue
                var thumbNail = "nothumb"
                if post.1["data"]["thumbnail"].exists(){
                    thumbNail = post.1["data"]["thumbnail"].stringValue
                }
                
                let currentTime = Double(Date().timeIntervalSince1970)
                
                rawTime = rawTime - currentTime
                
                var intTime = 0
                var time = ""
                
                if rawTime > 3600{
                    rawTime = rawTime/3600
                    intTime = Int(rawTime)
                    time = String(describing: intTime) + "h"
                }else{
                    rawTime = rawTime/60
                    intTime = Int(rawTime)
                    time = String(describing: intTime) + "m"
                }
                
                var score = ""
                
                if rawScore > 1000{
                    rawScore = rawScore/1000
                    rawScore = self.roundDown(rawScore, toNearest: 0.1)
                    score = String(describing: rawScore) + "k"
                }
                
                
                let urlType = url.suffix(4)
                var type = ""
                if(urlType.contains("png") || urlType.contains("jpg")){
                    type = "image"
                }else if(urlType.contains("gif") || urlType.contains("gifv")){
                    type = "gif"
                }else if(selfText != ""){
                    type = "text"
                }else{
                    type = "link"
                }
                
                let newPost = Post(title: title, type: type, url: url, subreddit: subreddit, upvotes: score, time: time, thumbnail: thumbNail)
                
                self.posts.append(newPost)
            }
            
            self.postsTableView.reloadData()
            
        }
        
    }
    
    @objc func openWebPage(_ button: UIButton) {
        self.curUrl = button.currentTitle!
        self.performSegue(withIdentifier: "openWebsite", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func roundDown(_ value: Double, toNearest: Double) -> Double {
        return floor(value / toNearest) * toNearest
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        switch posts[indexPath.item].type{
        case "text"?:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath) as? TextTableViewCell  else {
                fatalError("The dequeued cell is not an instance of TextTableViewCell.")
            }
            
            cell.titleLabel.text = posts[indexPath.item].title
            
            return cell
        case "link"?:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "linkCell", for: indexPath) as? LinkTableViewCell  else {
                fatalError("The dequeued cell is not an instance of TextTableViewCell.")
            }
            
            if posts[indexPath.item].thumbnail! != "nothumb"{
                let url = URL(string: posts[indexPath.item].thumbnail!)
                let data = try? Data(contentsOf: url!)
                
                if data != nil {
                    
                    let image = UIImage(data: data!)
                    
                    cell.linkButton.setBackgroundImage(image, for: .normal)
                }
            }
            
            
            cell.titleLabel.text = posts[indexPath.item].title
            cell.subredditLabel.text = "r/" + posts[indexPath.item].subreddit!
            cell.upvotesLabel.text = "^ " + posts[indexPath.item].upvotes!
            cell.linkButton.setTitle(posts[indexPath.item].url, for: .normal)
            cell.timeLabel.text = posts[indexPath.item].time!
            cell.linkButton.addTarget(self, action: #selector(self.openWebPage(_:)), for: .touchUpInside)
            self.curUrl = posts[indexPath.item].url!
            
            return cell
        case "image"?:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as? ImageTableViewCell  else {
                fatalError("The dequeued cell is not an instance of ImageTableViewCell.")
            }
            
            let url = URL(string: posts[indexPath.item].url!)
            let data = try? Data(contentsOf: url!)
            
            if data != nil {
                
                var image = UIImage(data: data!)
                
                //var image = UIImage.gifImageWithData(data: data! as NSData)
                
                let ratio = image!.size.width/image!.size.height
                
                let newSize = CGSize(width: cell.postImageView.frame.size.width, height: cell.postImageView.frame.size.width/ratio)
            
                image = image?.resizeImageWith(newSize: newSize)
                
                cell.postImageView.image = image
            }
            
            cell.titleLabel.text = posts[indexPath.item].title
            cell.subredditLabel.text = "r/" + posts[indexPath.item].subreddit!
            cell.upvotesLabel.text = "^ " + posts[indexPath.item].upvotes!
            cell.timeLabel.text = posts[indexPath.item].time!
            
            return cell
        case "gif"?:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "gifCell", for: indexPath) as? GifTableViewCell  else {
                fatalError("The dequeued cell is not an instance of ImageTableViewCell.")
            }
            
            cell.titleLabel.text = posts[indexPath.item].title
            
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath) as? TextTableViewCell  else {
                fatalError("The dequeued cell is not an instance of TextTableViewCell.")
            }
            
            cell.titleLabel.text = "Unknown Post"
            
            return cell
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openWebsite" {
            if let webViewController = segue.destination as? WebViewController {
                webViewController.urlString = self.curUrl
            }
        }
    }


}

class Post {
    var title: String?
    var type: String?
    var url: String?
    var subreddit: String?
    var upvotes: String?
    var time: String?
    var thumbnail: String?
    
    init(title: String, type: String, url: String, subreddit: String, upvotes: String?, time: String?, thumbnail: String?) {
        self.title = title
        self.type = type
        self.url = url
        self.subreddit = subreddit
        self.upvotes = upvotes
        self.time = time
        self.thumbnail = thumbnail
    }
    
}

extension UIImage{
    
    func resizeImageWith(newSize: CGSize) -> UIImage {
        
        let horizontalRatio = newSize.width / size.width
        let verticalRatio = newSize.height / size.height
        
        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    public class func gifImageWithData(data: NSData) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data, nil) else {
            print("image doesn't exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source: source)
    }
    
    public class func gifImageWithURL(gifUrl:String) -> UIImage? {
        guard let bundleURL = NSURL(string: gifUrl)
            else {
                print("image named \"\(gifUrl)\" doesn't exist")
                return nil
        }
        guard let imageData = NSData(contentsOf: bundleURL as URL) else {
            print("image named \"\(gifUrl)\" into NSData")
            return nil
        }
        
        return gifImageWithData(data: imageData)
    }
    
    public class func gifImageWithName(name: String) -> UIImage? {
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                print("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        
        guard let imageData = NSData(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gifImageWithData(data: imageData)
    }
    
    class func delayForImageAtIndex(index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(CFDictionaryGetValue(cfProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()), to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()), to: AnyObject.self)
        
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as! Double
        
        if delay < 0.1 {
            delay = 0.1
        }
        
        return delay
    }
    
    class func gcdForPair(a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        if a! < b! {
            let c = a!
            a = b!
            b = c
        }
        
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b!
            } else {
                a = b!
                b = rest
            }
        }
    }
    
    class func gcdForArray(array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(a: val, gcd)
        }
        
        return gcd
    }
    
    class func animatedImageWithSource(source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(index: Int(i), source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        let gcd = gcdForArray(array: delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImage(with: frames, duration: Double(duration) / 1000.0)
        
        return animation
    }
    
    
}

