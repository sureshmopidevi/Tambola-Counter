//
//  ViewController.swift
//  Tambola Counter
//
//  Created by APPLE  on 04/04/20.
//  Copyright © 2020 Suresh Mopidevi. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet var currentValueLabel: UILabel!
    @IBOutlet var counterList: UICollectionView!
    
    @IBOutlet var nextNumberButton: UIButton!
    @IBOutlet var resetButton: UIButton!
   
    
    var numbersData: [NumberModel] = []
    
     let synth:AVSpeechSynthesizer = {
        let synth:AVSpeechSynthesizer = AVSpeechSynthesizer()
        return synth
    }()
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareCount()
        title = "Tambola Counter"
        currentValueLabel.text = "START"
        nextNumberButton.setTitle("START", for: .normal)
        nextNumberButton.setTitle("END", for: .disabled)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.9066922987, green: 0.9909882941, blue: 1, alpha: 1)
        counterList.backgroundColor = #colorLiteral(red: 0.9066922987, green: 0.9909882941, blue: 1, alpha: 1)
        currentValueLabel.textColor = .darkGray
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        counterList.register(TambolaCoinCell.self, forCellWithReuseIdentifier: "tambolaCoinCell")
        counterList.contentInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        counterList.collectionViewLayout = layout
        counterList.delegate = self
        counterList.dataSource = self
        nextNumberButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(didTapResetButton), for: .touchUpInside)
    }
    
    func prepareCount() {
        var data: [NumberModel] = []
        var cellData: NumberModel = NumberModel()
        for i in 1...90 {
            cellData.number = i
            cellData.isSelected = false
            data.append(cellData)
        }
        numbersData = data
        DispatchQueue.main.async {
            self.counterList.reloadData()
        }
    }
    
    @objc func didTapNextButton() {
        nextNumberButton.setTitle("NEXT", for: .normal)
        let sa = numbersData.filter { (number) -> Bool in
            number.isSelected == false
        }
        if let numberModel = sa.randomElement() {
            currentValueLabel.text = "\(numberModel.number)"
            synth.speak(numberModel.speakableData)
            numbersData[numberModel.number - 1].isSelected = true
            counterList.reloadItems(at: [IndexPath(item: numberModel.number - 1, section: 0)])
        } else {
            currentValueLabel.adjustsFontSizeToFitWidth = true
            currentValueLabel.text = "END"
            nextNumberButton.isEnabled = false
        }
    }
    
    @objc func didTapResetButton() {
        DispatchQueue.global(qos: .background).async {
            self.prepareCount()
        }
        nextNumberButton.isEnabled = true
        nextNumberButton.setTitle("START", for: .normal)
        currentValueLabel.text = "START"
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tambolaCoinCell", for: indexPath) as! TambolaCoinCell
        cell.updateUI(model: numbersData[indexPath.item])
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numbersData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 46, height: 46)
    }
}


class TambolaCoinCell:UICollectionViewCell {
    override var reuseIdentifier: String? {
        return "tambolaCoinCell"
    }
    let numberLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 23
        layer.masksToBounds = true
        self.contentView.addSubview(numberLabel)
        NSLayoutConstraint.activate([
            numberLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            numberLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            numberLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            numberLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            numberLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            numberLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateUI(model:NumberModel) {
        numberLabel.text = "\(model.number)"
        numberLabel.textColor = model.isSelected ? .white : .black
        self.contentView.backgroundColor  = model.isSelected ? #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1) : .clear
        layer.borderColor =  model.isSelected ? UIColor.clear.cgColor : UIColor.gray.cgColor
        layer.borderWidth = model.isSelected ? 0 : 1
    }
}

struct NumberModel {
    var number: Int = 0
    var isSelected: Bool = false
    var speakableData: AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: "\(number)")
        utterance.rate = 0.5
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        return utterance
    }
}
