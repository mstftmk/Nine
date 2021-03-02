//
//  ViewController.swift
//  RandomGame
//
//  Created by Mustafa Tomak on 1.04.2020.
//  Copyright © 2020 Mustafa Tomak. All rights reserved.
//

import UIKit
import JSSAlertView
import MessageUI
import GoogleMobileAds

class ViewController: UIViewController, MFMailComposeViewControllerDelegate, GADBannerViewDelegate {

    var highScore = UserDefaults.standard.integer(forKey: "HighScore")

    @IBOutlet weak var nineNumber: UILabel!
    @IBOutlet weak var nineWord: UILabel!
    @IBOutlet weak var playWord: UIButton!
    @IBOutlet weak var achievementsWord: UIButton!
    @IBOutlet weak var helpWord: UIButton!
    @IBOutlet weak var highScorex: UIButton!
    @IBOutlet weak var removeAdsx: UIButton!
    @IBOutlet weak var backgroundd: UIImageView!
    
    var bannerView: GADBannerView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        nineNumber.alpha = 0
        nineWord.alpha = 0
        nineNumber.fadeIn()
        nineWord.fadeIn()
        highScorex.alpha = 0
        removeAdsx.alpha = 0
        playWord.alpha = 0
        achievementsWord.alpha = 0
        helpWord.alpha = 0
        highScorex.fadeIn()
        removeAdsx.fadeIn()
        playWord.fadeIn()
        achievementsWord.fadeIn()
        helpWord.fadeIn()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        removeAdsx.isHidden = true
        backgroundd.isHidden = true
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" //Test Ad ID (Kendi Ad ID'niz ile değiştirin)
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        addBannerViewToView(bannerView)
        
    }


    func addBannerViewToView(_ bannerView: GADBannerView) {
      bannerView.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(bannerView)
        
        
      view.addConstraints(
        [NSLayoutConstraint(item: bannerView,
                            attribute: .top,
                            relatedBy: .equal,
                            toItem: topLayoutGuide,
                            attribute: .bottom,
                            multiplier: 1,
                            constant: 0),
         NSLayoutConstraint(item: bannerView,
                            attribute: .centerX,
                            relatedBy: .equal,
                            toItem: view,
                            attribute: .centerX,
                            multiplier: 1,
                            constant: 0)
        ])
  
     }
    
    @IBAction func playButton(_ sender: Any) {
        performSegue(withIdentifier: "play", sender: nil)
    }
    @IBAction func achievements(_ sender: Any) {
        var achievementView = JSSAlertView().show(self,
          title: "Coming soon..",
          text: "Achievements will be here soon.",
          buttonText: "Done",
          color: UIColorFromHex(0xFF7417, alpha: 1)
        )
        achievementView.setTextTheme(.light)
    }
    @IBAction func help(_ sender: Any) {
        let mailComposeViewController2 = configuredMailComposeViewController2()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController2, animated: true, completion: nil)
        }else{
            self.showSendMailError2()
        }
    }
    @IBAction func noAds(_ sender: Any) {
        var noAdd = JSSAlertView().show(self,
          title: "Coming soon..",
          text: "You can remove adds soon.",
          buttonText: "Done",
          color: UIColorFromHex(0xFF7417, alpha: 1)
        )
        noAdd.setTextTheme(.light)
  
    }
    @IBAction func highScore(_ sender: Any) {
        var shareView = JSSAlertView().show(self,
          title: "Share your score",
          text: "Your high score is: \(String(highScore)) ",
          buttonText: "Share",
          cancelButtonText: "Done",
          color: UIColorFromHex(0xFF7417, alpha: 1)
        )
        shareView.addAction(shareScore)
        shareView.setTextTheme(.light)
        
    }
    func shareScore() {
        let text = "My Highest score on Nine is \(String(highScore)), what about you?"
        let webSite = NSURL(string:"https://apps.apple.com/us/app/id1514485188")
        let textShare = [ text , webSite ] as [Any] //, image arada
        let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func configuredMailComposeViewController2() -> MFMailComposeViewController {
        let mailVC2 = MFMailComposeViewController()
        mailVC2.mailComposeDelegate = self
        mailVC2.setToRecipients(["9game.contact@gmail.com"])
        mailVC2.setSubject("Nine Game Player - Help")
        mailVC2.setMessageBody("", isHTML: false)
        
        return mailVC2
    }
    
    func showSendMailError2() {
        
        var errorView = JSSAlertView().show(self,
          title: "Could not send email",
          text: "Your device must have an active mail account.",
          buttonText: "Done",
          color: UIColorFromHex(0xFF7417, alpha: 1)
        )
        errorView.setTextTheme(.light)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
         UIView.animate(withDuration: 1, animations: {
           bannerView.alpha = 1
         })
        addBannerViewToView(bannerView)
      print("adViewDidReceiveAd")
    }

    // Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
        didFailToReceiveAdWithError error: GADRequestError) {
        bannerView.backgroundColor = UIColor.white
      print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    // Tells the delegate that a full-screen view will be presented in response
    // to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("adViewWillPresentScreen")
    }

    // Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("adViewWillDismissScreen")
    }

    // Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("adViewDidDismissScreen")
    }

    // Tells the delegate that a user click will open another app (such as
    // the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
      print("adViewWillLeaveApplication")
    }
    
}

extension UIView {
func fadeIn(duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
    UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
        self.alpha = 1.0
    }, completion: completion)
  }
    
    func fadeOut(duration: TimeInterval = 1.0, delay: TimeInterval = 3.0, completion: (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
            }, completion: nil)
    }
}
