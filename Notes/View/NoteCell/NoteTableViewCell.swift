//
//  NoteTableViewCell.swift
//  Notes
//
//  Created by Миландр on 19/07/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var colorView: ColorBoxView!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .darkGray
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        contentLabel.text = nil
        colorView.backgroundColor = nil
    }
    
    func setNoteItem(_ note: NotePresenter) {
        titleLabel.text = note.title
        contentLabel.text = note.content
        colorView.backgroundColor = note.color
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        titleLabel.textColor = selected ? UIColor.black : UIColor.white
    }
    
}
