//
//  DetailViewController.swift
//  NCNews
//
//  Created by Sean Molenaar on 10/01/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import UIKit
import SafariServices
import AlamofireImage

class DetailViewController: UIViewController, UIScrollViewDelegate, CanReloadView {
    var dataType: NCNewsObject.Type = FeedItem.self

    var detailItem: FeedItem?

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var feedLabel: UILabel!
    @IBOutlet weak var itemBody: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func configureView() {
        // Update the user interface for the detail item.
        guard let detail = detailItem else {
            return
        }
        if let label = itemBody, let body = detail.body {
            label.attributedText = ImageFinder.stringFromHtmlString(body)
            label.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
            label.isUserInteractionEnabled = true
            label.sizeToFit()
            self.view.sizeToFit()
        }
        if let label = titleLabel, let title = detail.title {
            label.text = title
            self.title = title
        }
        if let label = dateLabel, let date = detail.pubDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            label.text = formatter.string(from: date as Date)
        }
        if let label = authorLabel {
            let author = detail.author ?? "Unknown"
            label.text = "By: " + author
        }
        if let label = feedLabel, let title = detail.parent.title {
            label.text = title
        }
        if let imageView = self.image, let imageSting = detail.image, let imageURL = URL(string: imageSting) {
            let filter: ImageFilter = AspectScaledToFillSizeFilter(size: imageView.frame.size)
            imageView.af_setImage(withURL: imageURL, filter: filter)
        } else {
            image.removeFromSuperview()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = NCColor.custom
        navigationController?.navigationBar.tintColor = UIColor.lightText
        itemBody.isUserInteractionEnabled = true
        scrollView.delegate = self
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func restoreUserActivityState(_ activity: NSUserActivity) {
        debugPrint(activity)
    }

    func reloadData(_ pull: Bool = true) {
        configureView()
    }

    @IBAction func selectedFontSize(_ sender: Any) {
        print("User wants to change font")
    }

    @IBAction func selectedFavorite(_ sender: Any) {
        print("User wants to favorite")
    }

    @IBAction func selectedSafari(_ sender: Any) {
        if let url = detailItem?.url {
            let svc = SFSafariViewController(url: URL(string: url)!, entersReaderIfAvailable: true)
            present(svc, animated: true, completion: nil)
        }
    }

    @IBAction func selectedShare(_ sender: Any) {
        let textToShare = (detailItem?.title)! + " - " + (detailItem?.parent.title)!

        if let myWebsite = NSURL(string: (detailItem?.url)!) {
            let objectsToShare = [textToShare, myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

            activityVC.popoverPresentationController?.sourceView = sender as? UIView
            self.present(activityVC, animated: true, completion: nil)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if #available(iOS 11.0, *), scrollView.contentOffset.y <= 0 {
            self.navigationItem.largeTitleDisplayMode = .always
        } else if #available(iOS 11.0, *), scrollView.contentOffset.y > 0 {
            self.navigationItem.largeTitleDisplayMode = .never
        }
        self.navigationController?.navigationBar.setNeedsLayout()
        self.view.setNeedsLayout()
        UIView.animate(withDuration: 0.25, animations: {
            self.navigationController?.navigationBar.layoutIfNeeded()
            self.view.layoutIfNeeded()
        })
    }

}
