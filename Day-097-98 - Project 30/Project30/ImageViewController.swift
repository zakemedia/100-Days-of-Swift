//
//  ImageViewController.swift
//  Project30
//
//  Created by TwoStraws on 20/08/2016.
//  Copyright (c) 2016 TwoStraws. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
	// 9 - Video 6 - make it weak to break strong reference cycle
    weak var owner: SelectionViewController!
    
	var image: String!
	var animTimer: Timer!

	var imageView: UIImageView!

	override func loadView() {
		super.loadView()
		
		view.backgroundColor = UIColor.black

		// create an image view that fills the screen
		imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.alpha = 0

		view.addSubview(imageView)

		// make the image view fill the screen
		imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
		imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

		
        // 10 - Video 6 - animation is causing images to not be destroyed
        // timers hold a strong reference to it
        
        
        // schedule an animation that does something vaguely interesting
		animTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
			// do something exciting with our image
            
            // VC owns the timer and then the timer owns VC
			self.imageView.transform = CGAffineTransform.identity

			UIView.animate(withDuration: 3) {
				self.imageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
			}
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		title = image.replacingOccurrences(of: "-Large.jpg", with: "")
		
        // 7 - Video 6
        let path = Bundle.main.path(forResource: image, ofType: nil)! // force cause we know its in bundle
        
        let original = UIImage(contentsOfFile: path)!
        //let original = UIImage(named: image)! // cache images uneccessarily

		let renderer = UIGraphicsImageRenderer(size: original.size)

		let rounded = renderer.image { ctx in
			ctx.cgContext.addEllipse(in: CGRect(origin: CGPoint.zero, size: original.size))
			ctx.cgContext.closePath()

			original.draw(at: CGPoint.zero)
		}

		imageView.image = rounded
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		imageView.alpha = 0

		UIView.animate(withDuration: 3) { [unowned self] in
			self.imageView.alpha = 1
		}
	}
    
    // 11 - Video 6
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animTimer.invalidate() // stops timer, forces it to release its strong reference on the VC it belongs to, which breaks the strong refernce cycle
    }

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		let defaults = UserDefaults.standard
		var currentVal = defaults.integer(forKey: image)
		currentVal += 1

		defaults.set(currentVal, forKey:image)

		// tell the parent view controller that it should refresh its table counters when we go back
		owner.dirty = true
	}
}
