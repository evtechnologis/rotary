//
//  SMRotaryWheel.swift
//  RotaryWheel
//
//  Created by zhaofei on 2015-09-14.
//  Copyright © 2015 zhaofei. All rights reserved.
//

import UIKit
import QuartzCore


class SMRotaryWheel: UIControl {
    
    
    var delegate: SMRotaryProtocol?
    var container: UIView?
    var numberOfSections: Int  = 7
    var startTransform: CGAffineTransform = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 200.0)
    var deltaAngle : Float
    var sectors = [SMSector]()
    var currentSector: Int = 0
    var sectorLabel:UILabel = UILabel()
    let minAlphavalue: CGFloat = 0.6
    let maxAlphavalue: CGFloat = 1.0
    
    
    
    init(frame: CGRect, del: ViewController, sectionsNum: Int) {
        
        self.numberOfSections = sectionsNum
        delegate = del
        self.container = del.view
        self.deltaAngle = 0
        super.init(frame: frame)
        self.drawWheel()
        print("init delegate \(delegate)")
        print("del is \(del)")
        // 4 - Timer for rotating wheel
       // NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "rotate", userInfo: nil, repeats: true)
        
    }

     required init?(coder aDecoder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let touchPoint: CGPoint = touch.locationInView(self)
        
        // 1.1 - Get the distance from the center
        let dist = self.calculateDistanceFromCenter(touchPoint)
        print("dist=\(dist)")
        // 1.2 - Filter out touches too close to the center
        if (dist < 40 || dist > 250)
        {
            // forcing a tap to be on the ferrule
            print("ignoring tap (%f,%f)", touchPoint.x, touchPoint.y);
            return false
        }
        
        let dx = touchPoint.x - (container?.center.x)!
        let dy = touchPoint.y - (container?.center.y)!
        
        deltaAngle = Float(atan2(dy, dx))
        startTransform = (container?.transform)!
        
        // set current sector's alpha value to the minimum value
        let im = self.getSectorByValue(currentSector)
        im.alpha = maxAlphavalue
        
        return true
    }
    
    
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        
        let touchPoint: CGPoint = touch.locationInView(self)
        
        // 1.1 - Get the distance from the center
        let dist = self.calculateDistanceFromCenter(touchPoint)
        
        // 1.2 - Filter out touches too close to the center
        if (dist < 40 || dist > 250)
        {
            // forcing a tap to be on the ferrule
            print("ignoring tap (%f,%f)", touchPoint.x, touchPoint.y);
            return false
        }

        
        
        let dx = touchPoint.x - (container?.center.x)!
        let dy = touchPoint.y - (container?.center.y)!
        
        let ang = atan2(dy, dx)
        let angleDifference = CGFloat(deltaAngle) - CGFloat(ang)
        container?.transform = CGAffineTransformRotate(startTransform, -angleDifference)
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        // 1- Get current container rotation in radians
        let radians = atan2f(Float((container?.transform.b)!), Float((container?.transform.a)!))
        print("rotated: \(radians * 180 / Float(M_PI))")
        // 2- Initialize new value
        var newVal = 0.0
        print("radians=\(radians)")
        // 3- Iterate through all the sectors
        for s in sectors{
            print("sectoer: \(s.sector), mid=\(s.midValue), min=\(s.minValue), max=\(s.maxValue)")
            
            // 4 - Check for anomaly (occurs with even number of sectors)
            if (s.minValue > 0 && s.maxValue < 0) {
                if (s.maxValue > radians || s.minValue < radians) {
                    // 5 - Find the quadrant (positive or negative)
                    if (radians > 0) {
                        newVal = Double(radians) - M_PI
                    } else {
                        newVal = M_PI + Double(radians)
                    }
                    currentSector = s.sector
                }
            }
                // 6 - All non-anomalous cases
            else if (radians > s.minValue && radians < s.maxValue) {
                newVal = Double(radians) - Double(s.midValue)
                currentSector = s.sector
            }
        }
        // 7- set up animation for final rotation
        UIView.animateWithDuration(0.2) {
            let t: CGAffineTransform = CGAffineTransformRotate(self.container!.transform, CGFloat(-newVal))
            self.container!.transform = t
        }
        print("current sector is \(self.currentSector)")
        
        // to check which label is on the current sector
        print(self.subviews.count)
        
        /*for case let lableInstance as UILabel in  self.subviews{
            
                print(lableInstance.text)
           
            
        }*/
        
        let labels = getLabelsInView()
        for label in labels {
            print(label.text)
        }
    
        
        self.delegate?.wheelDidChangeValue(String("\(convertWeekday(self.currentSector)) is selected"))
        
        let im = self.getSectorByValue(currentSector)
        im.alpha = maxAlphavalue
        
        
        
    }
    
    func getLabelsInView() -> [UILabel] {
        var results = [UILabel]()
        for subview in self.subviews as [UIView] {
            if let labelView = subview as? UILabel {
                results += [labelView]
            } else {
                results += getLabelsInView()
            }
        }
        return results
    }
    
    
    private func calculateDistanceFromCenter(point: CGPoint) -> Float{
        let center: CGPoint = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
       
        let dx = point.x - center.x
        let dy = point.y - center.y
        return Float(sqrt(dx*dx + dy*dy))
    }
    
    
    func btnTouched(){
        return
    }
    
   private func drawWheel() -> Void {
        container = UIView(frame: self.frame)
        let angleSize:CGFloat = CGFloat(2 * M_PI) / CGFloat(numberOfSections)
        let outerRidus:CGFloat = 180.0 // outer ring for weekday
        let innerRidus = 70.0  // inner ring for hours

        let calendar:NSCalendar = NSCalendar.currentCalendar()
        let dateComps:NSDateComponents = calendar.components(.Weekday , fromDate: NSDate())
        let todayWeekday:Int = dateComps.weekday
           
        print("today is \(todayWeekday)")
    
        let image = UIImage(named: "addButton.png") as UIImage?
        let add_btn = UIButton(type: UIButtonType.System) as UIButton
    
        add_btn.frame = CGRectMake(260, 250, 100, 100)
        add_btn.setImage(image, forState: .Normal)
        add_btn.addTarget(self, action: "btnTouched:", forControlEvents:.TouchUpInside)
        self.addSubview(add_btn)

    
        // Create the sectors
        for var i = 0; i < numberOfSections; ++i {
            
            // Create image view
            let im = UIImageView()
            im.image = UIImage(named: "segment.png")
            
            
            
            im.layer.anchorPoint = CGPointMake(1.0, 0.5)
            im.layer.position = CGPointMake((container?.bounds.size.width)!/2, (container?.bounds.size.height)!/2)
            im.transform = CGAffineTransformMakeRotation(angleSize * CGFloat(i))
            im.alpha = minAlphavalue
            im.tag = i
            
           
            if i == 0 {
                im.alpha = maxAlphavalue
            }
            
            self.addSubview(im)
            
            let ilabel = UILabel(frame: CGRectMake(0, 0, 50, 40))
            ilabel.backgroundColor = UIColor.clearColor()
            
            if i < 4 {
                ilabel.text = convertWeekday(((i + todayWeekday - 1) < 7) ? (i + todayWeekday - 1): (i + todayWeekday - 8))
            }else if i > 5{
                
                ilabel.text = convertWeekday(((todayWeekday - 1 - numberOfSections + i) > 0) ? (todayWeekday - 1 - numberOfSections + i): (todayWeekday - 1 - numberOfSections + i + 7))

            }else{
                ilabel.text = "tbd"
            }
            
            ilabel.textAlignment = .Center
             print("sector: = \(ilabel.text)")
            
            if i == 0{ // highlight today on the wheel
                print("make today purple: \(i)")
                ilabel.textColor = UIColor.purpleColor()
            }
            
            ilabel.layer.anchorPoint = CGPointMake(0.5, 0.5)
            ilabel.layer.position = CGPointMake((container?.bounds.size.width)!/2, (container?.bounds.size.height)!/2)
            
            var t = CGAffineTransformIdentity
            t = CGAffineTransformTranslate(t, -outerRidus * cos(CGFloat(i) * angleSize), outerRidus * sin(CGFloat(i) * angleSize))
            t = CGAffineTransformRotate(t, CGFloat(M_PI / 2.0) - angleSize * CGFloat(i) + CGFloat(M_PI) )
           
            ilabel.transform = t
            
            ilabel.tag = i
            container?.addSubview(ilabel)
            // 5- Set sector image
            /*let sectorImage = UIImageView(frame: CGRectMake(12, 15, 40, 40))
            sectorImage.image = UIImage(named: String(format: "icon%i.png", i))
            im.addSubview(sectorImage)
            container?.addSubview(im)*/
        }
    
        container?.userInteractionEnabled = false
        self.addSubview(container!)
    
        let bg = UIImageView(frame: self.frame)
        bg.image = UIImage(named: "wheel2.png")
        self.addSubview(bg)
    
        //let mask = UIImageView(frame: CGRectMake(72, 175, 58, 58))
       // mask.image = UIImage(named: "centerButton.png")
       // self.addSubview(mask)
    
        // 8 - Initialize sectors
    
        if numberOfSections % 2 == 0{
            self.buildSectorsEven()
        }else
        {
            self.buildSectorsOdd()
        }
    
        // 9- Call protocol method
        print("delegate is \(self.delegate)")
        self.delegate?.wheelDidChangeValue(String("\(convertWeekday(todayWeekday - 1)) is selected"))
    }
    
    private func getSectorByValue(value: Int) -> UIImageView{
        var res = UIImageView()
        let views = [container?.subviews]
        for im in views {
            if let imageView = im as? UIImageView {
                if imageView.tag == value {
                    res = imageView
                }
            }
            
        }
        return res
    }

    
    
    /*func rotate() -> Void {
        let t: CGAffineTransform = CGAffineTransformRotate(container!.transform, -0.78)
        container!.transform = t
    }*/
    
    func buildSectorsOdd() -> Void {
        // 1 - Define sector length
        let fanWidth = M_PI * 2 / Double(numberOfSections)
        // 2 - Set initial midpoint
        var mid: Float = 0
        
        // 3 - Iterate through all sectors
        for var i = 0; i < numberOfSections; ++i {
            let sector = SMSector.init()
            
            // 4 - Set sector values
            sector.midValue = mid
            sector.minValue = mid - (Float(fanWidth)/2)
            sector.maxValue = mid + (Float(fanWidth)/2)
            sector.sector = i
            
            mid -= Float(fanWidth)
            
            if abs(sector.minValue - Float(-M_PI)) < 0.01 {
                mid = -mid
                mid -= Float(fanWidth)
            }
            
            // 5 - Add sector to arry
            sectors.append(sector)
            //print("sector minvalue=\(sector.minValue)")
            //print("sector: \(sector.sector), mid:\(sector.midValue * 180 / Float(M_PI)))")
            
        }
    }
    
    func buildSectorsEven() -> Void {
        // 1 - Define sector length
        let fanWidth = M_PI * 2 / Double(numberOfSections)
        // 2 - Set initial midpoint
        var mid: Float = 0
        
        // 3 - Iterate through all sectors
        for var i = 0; i < numberOfSections; ++i {
            let sector = SMSector.init()
            
            // 4 - Set sector values
            sector.midValue = mid
            sector.minValue = mid - (Float(fanWidth)/2)
            sector.maxValue = mid + (Float(fanWidth)/2)
            sector.sector = i
            
            if (sector.maxValue - Float(fanWidth)) < Float(-M_PI){
                mid = Float(M_PI)
                sector.midValue = mid
                sector.minValue = fabsf(sector.maxValue)
            }
            mid -= Float(fanWidth)
            print("cl is \(sector.midValue)")
            
            // 5 - Add sector to arry
            sectors.append(sector)
            
            
        }
    }
    
    private func convertWeekday(number: Int) -> String{
        switch number{
        case 0:
            return "SUN"
        case 1:
            return "MON"
        case 2:
            return "TUE"
        case 3:
            return "WED"
        case 4:
            return "THU"
        case 5:
            return "FRI"
        case 6:
            return "SAT"
        default:
            return "SUN"
        }
    }
    
    

    
    
   
}
