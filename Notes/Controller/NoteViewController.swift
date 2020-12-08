//
//  NoteViewController.swift
//  Notes
//
//  Created by Timur on 12/8/20.
//

import UIKit

class NoteViewController: UIViewController {
    
    var note: Note!
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = note.contents
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        note.contents = textView.text
        NoteManager.main.save(note)
        
    }

}
