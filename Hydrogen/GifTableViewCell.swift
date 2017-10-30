//
//  GifTableViewCell.swift
//  Hydrogen
//
//  Created by Jacob Bashista on 10/26/17.
//  Copyright © 2017 Jacob Bashista. All rights reserved.
//

import UIKit

class GifTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
