//
//  PlayVC.swift
//  RandomGame
//
//  Created by Mustafa Tomak on 4.04.2020.
//  Copyright © 2020 Mustafa Tomak. All rights reserved.
//

import UIKit
import JSSAlertView
import GoogleMobileAds

class PlayVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GADBannerViewDelegate, GADInterstitialDelegate {
    
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var levelArea: UILabel!
    @IBOutlet weak var highScore: UILabel!
    @IBOutlet weak var scoreArea: UILabel!
    @IBOutlet weak var countdownArea: UILabel!
    @IBOutlet weak var playArea: UICollectionView!
    @IBOutlet weak var showNumber: UILabel!
    
    var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    
    var numbers = Array(1...9)
    let randomNumber = Int.random(in: 1..<10)
    var level = 1
    var score = 0
    var count = 10
    var gameTimer = Timer()
    var changeTimer = Timer()
    var areaTimer = Timer()
    var truefalseTimer = Timer()
    var highScr = UserDefaults.standard.integer(forKey: "HighScore")
    let reuseIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundImage.isHidden = true
        playArea.delegate = self
        playArea.dataSource = self
        playArea.allowsSelection = true
        pauseButton.isHidden = false
        playArea.isHidden = false
        pauseButton.layer.cornerRadius = 15
        pauseButton.clipsToBounds = true
        pauseButton.layer.backgroundColor = UIColor.white.cgColor
        levelArea.text = String(level)
        showNumber.text = String(randomNumber)
        scoreArea.text = String(score)
        countdownArea.text = String(count)
        highScore.text = String(highScr)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)

        
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" //Test Ad ID (Kendi Ad ID'niz ile değiştirin)
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        addBannerViewToView(bannerView)
        
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910") //Test Ad ID (Kendi Ad ID'niz ile değiştirin)
        interstitial.delegate = self
        let request = GADRequest()
        interstitial.load(request)
        interstitial = createAndLoadInterstitial()

    }
    
    func pauseGameMenu() {
        playArea.isHidden = true
        pauseButton.isHidden = true
        gameTimer.invalidate()
        areaTimer.invalidate() //dikkat
        
        var pauseView = JSSAlertView().show(self,
          title: "Pause",
          text: "Game Paused",
          buttonText: "Continue",
          cancelButtonText: "End Game",
          color: UIColorFromHex(0xBF0A30, alpha: 1)
          
        )
        pauseView.addAction(continueGame)
        pauseView.addCancelAction(endGame)
        pauseView.setTextTheme(.light)
        
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
      var interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910") //Test Ad ID (Kendi Ad ID'niz ile değiştirin)
      interstitial.delegate = self
      interstitial.load(GADRequest())
      return interstitial
    }

    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
      interstitial = createAndLoadInterstitial()
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
      bannerView.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(bannerView)
        
        var deviceModel = UIDevice.modelName
        print(deviceModel)
        if deviceModel == "iPhone 8" {
            bannerView.adSize = GADAdSizeFromCGSize(CGSize(width: 255, height: 50))
        } else {
            bannerView.adSize = GADAdSizeFromCGSize(CGSize(width: 290, height: 50))
        }
        
        
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
    
    
    @IBAction func pauseGame(_ sender: Any) {
        pauseGameMenu()
    }
    
    func continueGame() {
        playArea.isHidden = false
        pauseButton.isHidden = false
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        switch level {
        case 1...3 :
            print("level1-3 kısmı")
        case 3...5 :
            areaTimer = Timer.scheduledTimer(timeInterval: 3.5, target: self, selector: #selector(timerChange), userInfo: nil, repeats: false)
        case 5...7 :
            areaTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(timerChange), userInfo: nil, repeats: false)
            print("level5")
        case 7...10 :
            areaTimer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(timerChange), userInfo: nil, repeats: false)
            print("level7")
        case 11... :
            areaTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(timerChange), userInfo: nil, repeats: false)
        default :
            print("level0")
        }
    }
    
    func endGame() {
        performSegue(withIdentifier: "goToMainVC", sender: self)
    }
    
    func goBack() {
        performSegue(withIdentifier: "goToMainVC", sender: self)
    }
    
    @objc func updateCounter() {
        if count <= 4 {
            countdownArea.textColor = UIColor.red
        } else {
            countdownArea.textColor = UIColor.white
        }
        
        if count > 0 {
            count -= 1
            countdownArea.text = String(count)
            playArea.allowsSelection = true
        } else {
            if interstitial.isReady {
              gameTimer.invalidate()
              areaTimer.invalidate()
              interstitial.present(fromRootViewController: self)
            } else {
              print("Ad wasn't ready")
            }

            countdownArea.text = String(0)
            print("GAME OVER")
            gameTimer.invalidate()
            areaTimer.invalidate()
            playArea.allowsSelection = false
            var alertview = JSSAlertView().show(self,
              title: "Game Over",
              text: "Your score is: \(score)",
              color: UIColorFromHex(0xBF0A30, alpha: 1)
            )
            alertview.addAction(goBack)
            alertview.setTextTheme(.light)
        }
    }
    
    func checkHighScore() {
        let oldScore = UserDefaults.standard.integer(forKey: "HighScore")
        
        if score > oldScore {
            UserDefaults.standard.set(score, forKey: "HighScore")
            print("NEW HIGHSCORE")
            highScore.text = String(score)
        }
    }
    
    func levelUp () {
        switch score {
        case 0...10 :
            level = 1
            levelArea.text = String(level)
            print("score0-10")
        case 11...20 :
            level = 2
            
            levelArea.text = String(level)
            print("score11-20")
        case 21...30 :
            level = 3
            levelArea.text = String(level)
            print("score21-30")
        case 31...40 :
            level = 4
            levelArea.text = String(level)
            print("score 31-40")
        case 41...50 :
            level = 5
            levelArea.text = String(level)
        case 51...60 :
            level = 6
            levelArea.text = String(level)
        case 61...70 :
            level = 7
            levelArea.text = String(level)
        case 71...80 :
            level = 8
            levelArea.text = String(level)
        case 81...90 :
            level = 9
            levelArea.text = String(level)
        case 91...100 :
            level = 10
            levelArea.text = String(level)
        case 100... :
            level = 11
            levelArea.text = String(level)
        default :
            print("default")
        }
    }
    
    func checkLevel() {
        switch level {
        case 1...3 :
            print("level1")
            numbers.shuffle()
            playArea.reloadData()
        case 3...5 :
            levelArea.text = String(level)
            numbers.shuffle()
            playArea.reloadData()
            areaTimer = Timer.scheduledTimer(timeInterval: 3.5, target: self, selector: #selector(timerChange), userInfo: nil, repeats: false)
            print("level3")
        case 5...7 :
            levelArea.text = String(level)
            numbers.shuffle()
            playArea.reloadData()
            areaTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(timerChange), userInfo: nil, repeats: false)
            print("level5")
        case 7...10 :
            levelArea.text = String(level)
            numbers.shuffle()
            playArea.reloadData()
            areaTimer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(timerChange), userInfo: nil, repeats: false)
            print("level7")
        case 11... :
            levelArea.text = String(level)
            numbers.shuffle()
            playArea.reloadData()
            areaTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(timerChange), userInfo: nil, repeats: false)
        default :
            numbers.shuffle()
            playArea.reloadData()
            levelArea.text = String(level)
            print("level0")
        }
    }
    
    @objc func timerChange() {
        areaTimer.invalidate()
        print("TİMER BASILDI")
        numbers.shuffle()
        playArea.reloadData()
        checkLevel()
    }
    
    @objc func truefalse() {
        showNumber.textColor = UIColor.white
        truefalseTimer.invalidate()
    }
    
    @objc func backToNormal() {
        scoreLabel.textColor = UIColor.white
        timeLabel.textColor = UIColor.white
        
    }
    
    func shuffleFindNumberArea() {
        let newRandomNumber = Int.random(in: 1..<10)
        showNumber.text = String(newRandomNumber)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numbers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! PlayTiles
 
        switch level {
        case 0...1 :
            cell.tileNumber.font = cell.tileNumber.font.withSize(30)
        case 2...3 :
            cell.tileNumber.font = cell.tileNumber.font.withSize(28)
        case 4...5 :
            cell.tileNumber.font = cell.tileNumber.font.withSize(26)
        case 6...7 :
            cell.tileNumber.font = cell.tileNumber.font.withSize(23)
        case 8...9 :
            cell.tileNumber.font = cell.tileNumber.font.withSize(20)
        case 10...11 :
            cell.tileNumber.font = cell.tileNumber.font.withSize(17)
        default :
            print("default")
        }
        
        cell.tileNumber.text = String(numbers[indexPath.row])
        
        return cell
        
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
        pauseGameMenu()
     }
    
    // Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {

      print("interstitialDidReceiveAd")
    }

    // Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
      print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    // Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
      print("interstitialWillPresentScreen")
    }

    // Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        switch level {
        case 1...3 :
            print("level1-3 kısmı")
        case 3...5 : //5 saniyede 1 değişsin
            areaTimer = Timer.scheduledTimer(timeInterval: 3.5, target: self, selector: #selector(timerChange), userInfo: nil, repeats: false)
        case 5...7 : //4,5
            areaTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(timerChange), userInfo: nil, repeats: false)
            print("level5")
        case 7...10 : //4
            areaTimer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(timerChange), userInfo: nil, repeats: false)
            print("level7")
        case 11... : //3,5
            areaTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(timerChange), userInfo: nil, repeats: false)
        default :
            print("level0")
        }
      print("interstitialWillDismissScreen")
    }

    // Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreenn(_ ad: GADInterstitial) {
      print("interstitialDidDismissScreen")
    }

    // Tells the delegate that a user click will open another app
    // (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
      print("interstitialWillLeaveApplication")
    }
     
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let bas = numbers[indexPath.row]
        print("You selected cell #\(bas)!")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! PlayTiles
        areaTimer.invalidate()
        
        if bas == Int(showNumber.text!) {
            showNumber.textColor = UIColor.green
            truefalseTimer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(truefalse), userInfo: nil, repeats: false)
            
            if level < 3 {
                count += 2
            } else if 3 < level && level < 6{
                count += Int(1.2)
            } else {
                count += 1
            }
            
            if score == 20 || score == 50 || score == 80{
                if interstitial.isReady {
                  gameTimer.invalidate()
                  areaTimer.invalidate()
                  interstitial.present(fromRootViewController: self)
                } else {
                  print("Ad wasn't ready")
                }

            }
            
            score += 1
            scoreArea.text = String(score)
            scoreLabel.textColor = UIColor.green
            changeTimer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(backToNormal), userInfo: nil, repeats: false)
        } else {
            showNumber.textColor = UIColor.red

            truefalseTimer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(truefalse), userInfo: nil, repeats: false)

            count -= 2
            timeLabel.textColor = UIColor.red
            changeTimer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(backToNormal), userInfo: nil, repeats: false)
        }
        shuffleFindNumberArea()
        checkHighScore()

        levelUp()
        checkLevel()
        
     }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let yourWidth = playArea.bounds.width/3.0
        let yourHeight = yourWidth

        return CGSize(width: yourWidth, height: yourHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

}

import UIKit

public extension UIDevice {

    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        func mapToDevice(identifier: String) -> String {
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod touch (5th generation)"
            case "iPod7,1":                                 return "iPod touch (6th generation)"
            case "iPod9,1":                                 return "iPod touch (7th generation)"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPhone12,1":                              return "iPhone 11"
            case "iPhone12,3":                              return "iPhone 11 Pro"
            case "iPhone12,5":                              return "iPhone 11 Pro Max"
            case "iPhone12,8":                              return "iPhone SE (2nd generation)"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad (3rd generation)"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad (4th generation)"
            case "iPad6,11", "iPad6,12":                    return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                      return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                    return "iPad (7th generation)"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad11,4", "iPad11,5":                    return "iPad Air (3rd generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad mini 4"
            case "iPad11,1", "iPad11,2":                    return "iPad mini (5th generation)"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
            case "iPad8,9", "iPad8,10":                     return "iPad Pro (11-inch) (2nd generation)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "iPad8,11", "iPad8,12":                    return "iPad Pro (12.9-inch) (4th generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }

        return mapToDevice(identifier: identifier)
    }()

}
