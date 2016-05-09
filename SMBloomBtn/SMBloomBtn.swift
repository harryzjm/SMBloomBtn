//
//  SMBloomBtn.swift
//  SMBloomBtn
//
//  Created by Magic on 4/5/2016.
//  Copyright © 2016 Magic. All rights reserved.
//

import Foundation
import UIKit

public class SMBloomBtn: UIButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public init(selectImg: UIImage, UnselectImg: UIImage) {
        super.init(frame: CGRectZero)
        self.selectImg = selectImg
        self.UnselectImg = UnselectImg
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var selectImg: UIImage = UIImage(imageLiteral: "star")
    public var UnselectImg: UIImage = UIImage(imageLiteral: "unstar")
    
    private func initialize() {
        addSubview(bloomV)
        NSLayoutConstraint.activateConstraints([
            bloomV.centerXAnchor.constraintEqualToAnchor(centerXAnchor),
            bloomV.centerYAnchor.constraintEqualToAnchor(centerYAnchor)])
        
        setImage(UnselectImg, forState: .Normal)
        sizeToFit()
        
        addTarget(self, action: #selector(SMBloomBtn.charge), forControlEvents: .TouchDown)
        addTarget(self, action: #selector(SMBloomBtn.bloom), forControlEvents: .TouchUpInside)
        addTarget(self, action: #selector(SMBloomBtn.cancel), forControlEvents: [.TouchUpOutside,.TouchCancel])
    }
    
    public func setBloomColor(color: UIColor) {
        bloomV.configBloomV { (cell) in
            cell.color = color.CGColor
            cell.redRange = 0
            cell.blueRange = 0
            cell.greenRange = 0
        }
    }
    
    private lazy var bloomV: SMBloomV = {
        let v = SMBloomV()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    //MARK:- Private Func
    private var stared: Bool = false
    @objc private func charge() {
        if !stared {
            bloomV.begin()
            UIView.animateWithDuration(0.3) { [weak self] in
                self?.transform = CGAffineTransformMakeScale(1.7, 1.7)
            }
        }
    }
    
    @objc private func bloom() {
        stared = !stared
        setImage(stared ? selectImg:UnselectImg, forState: .Normal)
        bloomV.bloom()
        over()
    }
    
    @objc private func cancel() {
        bloomV.end()
        over()
    }
    
    private func over() {
        self.transform = CGAffineTransformIdentity
        let am = CAKeyframeAnimation(keyPath: "transform")
        am.values = [NSValue(CATransform3D: CATransform3DMakeScale(0.7, 0.7, 1)),
                     NSValue(CATransform3D: CATransform3DMakeScale(1, 1, 1))]
        am.calculationMode = kCAAnimationPaced
        self.layer .addAnimation(am, forKey: "transform")
    }
}

private class SMBloomV: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        userInteractionEnabled = false
        
        layer.addSublayer(chargeLy)
        layer.addSublayer(bloomLy)
        
        configBloomV { (cell) in
            cell.contents = UIImage.imageFrom(.whiteColor()).CGImage
            cell.redRange = 2
            cell.blueRange = 2
            cell.greenRange = 2
            cell.alphaRange = 1
            cell.alphaSpeed = -1.0
            cell.scale = 2
            cell.scaleRange = 0.5
            cell.birthRate = 0
        }
    }
    
    func configBloomV(@noescape block: CAEmitterCell -> Void) {
        for cell in [chargeLy.emitterCells!,bloomLy.emitterCells!].flatten(){
            block(cell)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Life
    func begin() {
        chargeLy.beginTime = CACurrentMediaTime()
        chargeLy.setValue(100, forKeyPath: "emitterCells.charge.birthRate")
    }
    
    func bloom() {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            [weak self] in
            guard let wSelf = self else { return }
            wSelf.chargeLy.setValue(0, forKeyPath: "emitterCells.charge.birthRate")
            wSelf.bloomLy.beginTime = CACurrentMediaTime()
            wSelf.bloomLy.setValue(998, forKeyPath: "emitterCells.bloom.birthRate")
            wSelf.end()
        }
    }
    
    func end() {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            [weak self] in
            guard let wSelf = self else { return }
            wSelf.chargeLy.setValue(0, forKeyPath: "emitterCells.charge.birthRate")
            wSelf.bloomLy.setValue(0, forKeyPath: "emitterCells.bloom.birthRate")
        }
    }
    
    //MARK:- UI
    lazy var chargeLy: CAEmitterLayer = {
        let cell = CAEmitterCell()
        cell.name = "charge"
        cell.lifetime = 0.5
        cell.lifetimeRange = 0.1
        cell.velocity = -120.0
        cell.velocityRange = 0.00
        
        let ly = CAEmitterLayer()
        ly.emitterShape = kCAEmitterLayerCircle
        ly.emitterMode = kCAEmitterLayerOutline
        ly.emitterSize = CGSizeMake(100, 0)
        ly.emitterCells = [cell]
        ly.renderMode = kCAEmitterLayerOldestFirst
        ly.seed = 998
        return ly
    }()
    
    lazy var bloomLy: CAEmitterLayer = {
        let cell = CAEmitterCell()
        cell.name = "bloom"
        cell.lifetime = 0.7
        cell.lifetimeRange = 0.3
        cell.velocity = 40.00
        cell.velocityRange = 10.00
        
        let ly = CAEmitterLayer()
        ly.emitterShape = kCAEmitterLayerCircle
        ly.emitterMode = kCAEmitterLayerOutline
        ly.emitterSize = CGSizeMake(25, 0)
        ly.emitterCells = [cell]
        ly.renderMode = kCAEmitterLayerOldestFirst
        ly.seed = 998
        return ly
    }()
}

private extension UIImage {
    class func imageFrom(color: UIColor) -> UIImage {
        let rect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        defer{ UIGraphicsEndImageContext() }
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

