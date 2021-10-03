//
//  ViewController.swift
//  AstroPix
//
//  Created by Harish_Heathrow on 02/10/21.
//

import UIKit

class APODViewController: UIViewController {
    
    let model = APODViewModel()
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var apodExplanation: UITextView!
    @IBOutlet weak var datePIcker: UIDatePicker!
    @IBOutlet weak var apodImage: UIImageView!
    @IBOutlet weak var apodTitle: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        apodExplanation.isEditable = false
        datePIcker.maximumDate = Date()
        
        if model.checkRecordExists(date: Date()) {
            let apod: AstroData = model.fetchFromStore(date: Date())!
            DispatchQueue.main.async {
                self.updateUIFrom(astroData: apod)
            }
        }
        else {
            activityIndicator.startAnimating()
            apodImage.image = nil
            model.getImageData(date: Date()) { [weak self]result in
            switch result {
            case .failure(let error):
                    self?.activityIndicator.stopAnimating()
                    print(error)
                
            case .success(let apod):
                DispatchQueue.main.async {
                    self?.updateUI(apod: apod)
                }
                self?.model.saveToStore(apod: apod)
            }
        }
        
        }
    }
    
    @IBAction func dateSelected(_ sender: UIDatePicker) {
        if model.checkRecordExists(date: sender.date) {
            print("checking in store")
            let apod: AstroData = model.fetchFromStore(date: sender.date)!
            DispatchQueue.main.async {
                self.updateUIFrom(astroData: apod)
            }
        }
        else{
            activityIndicator.startAnimating()
            apodImage.image = nil
            model.getImageData(date: sender.date) { [weak self] result in
            switch result {
            case .failure(let error):
                print ("failure", error)
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                }
            case .success(let apod):
                DispatchQueue.main.async {
                    self?.updateUI(apod: apod)
                }
                self?.model.saveToStore(apod: apod)
            }
        }
        }

    }
    
    @IBAction func favouriteTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.setImage(UIImage(systemName: "heart"), for: .normal)
        sender.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        let date = datePIcker.date
        model.updateFavouriteFromStore(date: date, isFavourite: sender.isSelected)
    }
    func updateUIFrom(astroData: AstroData){
        activityIndicator.stopAnimating()
        apodImage.image = UIImage(data: astroData.image!)
        apodExplanation.text = astroData.explanation
        favouriteButton.isSelected = astroData.isFavourite
        apodTitle.text = astroData.title
    }
    func updateUI(apod:APOD) {
        apodImage.imageFromURL(urlString: apod.url)
        apodExplanation.text = apod.explanation
        favouriteButton.isSelected = false
        apodTitle.text = apod.title
        activityIndicator.stopAnimating()
    }
}
extension UIImageView {
    
    public func imageFromURL(urlString: String) {
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error ?? "No Error")
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
            })
            
        }).resume()
    }
    
    
}
