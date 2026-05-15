//
//  Extension+ImageView.swift
//  SourceQuiz
//
//  Created by Mạc Văn Vinh on 17/4/26.
//

import UIKit

extension UIImageView {
    
    func loadImage(from urlString: String) {
        self.image = nil
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data,
                  let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self?.image = image
            }
        }.resume()
    }
}
