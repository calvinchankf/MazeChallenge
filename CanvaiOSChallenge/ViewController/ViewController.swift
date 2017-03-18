//
//  ViewController.swift
//  CanvaiOSChallenge
//
//  Created by calvin on 17/3/2017.
//  Copyright © 2017年 me.calvinchankf. All rights reserved.
//

import UIKit

// life cycle
class ViewController: UIViewController {
    
    let mazeModel = MazeModel()
    var rooms = [[Room]]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib.init(nibName: "RoomCell", bundle: nil), forCellWithReuseIdentifier: "RoomCell")
        
        self.stopLoading()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func generatePressed(_ sender: Any) {
        if self.mazeModel.isGenerating {
            let alert = UIAlertController(title: "Hey", message: "The maze is generating, you want to stop and generate a new one?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler:{ (action) in
                
                self.reGenerateMaze()
            }))
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.destructive, handler:nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.startGenerateMaze()
        }
    }
}

// maze
extension ViewController {
    
    func startGenerateMaze() {
        
        self.rooms.removeAll()
        self.collectionView.reloadData()
        
        self.startLoading()
        
        self.mazeModel.generate()
        self.mazeModel.generateComplete = { (rooms, error) in
            DispatchQueue.main.async { [weak self] in
                if let error = error {
                    self?.stopLoading()
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Oh...", style: UIAlertActionStyle.cancel, handler:nil))
                    self?.present(alert, animated: true, completion: nil)
                } else if let rooms = rooms {
                    self?.rooms = rooms
                    self?.stopLoading()
                    self?.collectionView.reloadData()
                }
            }
        }
    }
    
    func reGenerateMaze() {
        self.mazeModel.reGenerate()
    }
}

// activity indicator
extension ViewController {
    func startLoading() {
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
    }
    
    func stopLoading() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    }
}

// collectionview
extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.rooms.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  self.rooms[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoomCell", for: indexPath) as! RoomCell
        cell.display(room: self.rooms[indexPath.section][indexPath.row])
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.rooms.count > 0 {
            let cnt = CGFloat(self.rooms[indexPath.section].count)
            let width = self.collectionView.frame.width / cnt
            return CGSize(width: width, height: width)
        }
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
