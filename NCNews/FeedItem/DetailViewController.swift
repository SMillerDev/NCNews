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

class DetailViewController: UIViewController {

    var detailItem: FeedItem?

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var feedLabel: UILabel!
    @IBOutlet weak var itemBody: UILabel!

    func configureView() {
        // Update the user interface for the detail item.
        guard let detail = detailItem else {
            return
        }
        if let label = itemBody, let body = detail.body {
            label.attributedText = stringFromHtml(string: body)
            label.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
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
            self.image.removeFromSuperview()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = NCColor.custom
        navigationController?.navigationBar.tintColor = UIColor.lightText
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func selectedFontSize(_ sender: Any) {
    }

    @IBAction func selectedFavorite(_ sender: Any) {
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

    private func stringFromHtml(string: String) -> NSAttributedString? {
        let myRegex = "<img.*?/>"
        let fix = string.replacingOccurrences(of: myRegex, with: "", options: .regularExpression, range: nil)
        let data = fix.data(using: .utf16)
        guard let d = data else {
            return nil
        }
        do {
            let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
            let str = try NSAttributedString(data: d, options: options, documentAttributes: nil)
            return str
        } catch {
        }
        return nil
    }

}
