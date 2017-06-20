//
//  matchRequestTableViewCell.swift
//  whober
//
//  Created by Adam Glasdstone on 19/6/17.
//  Copyright © 2017 swiftary. All rights reserved.
//

import UIKit

class matchRequestTableViewCell: UITableViewCell {

    //MARK: Properties
    
    @IBOutlet weak var matchRequestPhoto: UIImageView!
    
    
    @IBOutlet weak var matchRequestFirstName: UILabel!
    
    @IBOutlet weak var matchRequestSurname: UILabel!
    
    
    @IBOutlet weak var matchRequestStatus: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
