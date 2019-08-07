//
//  CMCountryCell.swift
//  CheckMobiSDK
//
//  Copyright (c) 2019 checkmobi. All rights reserved.
//

import UIKit
import AlamofireImage

class CMCountryCell: UITableViewCell {
    @IBOutlet var flagImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.flagImageView.image = nil
        self.titleLabel.text = ""
    }
    
    public func setupWith(country: Country) {
        self.titleLabel.text = "\(country.name ?? "") (+\(country.prefix ?? ""))"
        if let urlString = country.flagUrl,
            let url = URL(string: urlString) {
            self.flagImageView.af_setImage(withURL: url)
        } else {
            self.flagImageView.image = nil
        }
    }
}
