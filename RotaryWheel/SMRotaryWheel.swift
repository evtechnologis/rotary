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
        if (dist < 40 || dist > 100)
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
        
        //let radians: CGFloat = CGFloat(atan2f(Float((container?.transform.b)!), Float((container?.transform.a)!)))
        //print("rad is \(radians)")
        
        let touchPoint: CGPoint = touch.locationInView(self)
        
        // 1.1 - Get the distance from the center
        let dist = self.calculateDistanceFromCenter(touchPoint)
        
        // 1.2 - Filter out touches too close to the center
        if (dist < 40 || dist > 100)
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
        
        // 2- Initialize new value
        var newVal = 0.0
        
        // 3- Iterate through all the sectors
        for s in sectors{
            // 4 - Check for anomaly (occurs with even number of sectors)
            if (s.minValue > 0 && s.maxValue < 0) {
                if (s.maxValue > radians || s.minValue < radians) {
                    // 5 - Find the quadrant (positive or negative)
                    if (radians > 0) {
                        newVal = Double(radians) - M_PI
                    } else {
                        newVal = M_PI + Double(radians)
                    }
                    currentSector = s.sector;
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
            self.container!.transform = t;
        }
        print("current sector is \(self.currentSector)")
        
       // self.delegate?.wheelDidChangeValue(String(format:"value is %i", self.currentSector))
        self.delegate?.wheelDidChangeValue(String("\(convertWeekday(self.currentSector)) is selected"))
        
        let im = self.getSectorByValue(currentSector)
        im.alpha = maxAlphavalue
        
        
        
    }
    
    
    private func calculateDistanceFromCenter(point: CGPoint) -> Float{
        let center: CGPoint = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
       
        let dx = point.x - center.x
        let dy = point.y - center.y
        return Float(sqrt(dx*dx + dy*dy))
    }
    
    
    
    
    
   private func drawWheel() -> Void {
        container = UIView(frame: self.frame)
        let angleSize:CGFloat = CGFloat(2 * M_PI) / CGFloat(numberOfSections)
    
        let calendar:NSCalendar = NSCalendar.currentCalendar()
        let dateComps:NSDateComponents = calendar.components(.Weekday , fromDate: NSDate())
        let todayWeekday:Int = dateComps.weekday
    
        print("today is \(todayWeekday)")

    
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
            
            let ilabel = UILabel(frame: CGRectMake(0, 0, 100, 40))
            ilabel.backgroundColor = UIColor.clearColor()
            ilabel.text = convertWeekday(((i + todayWeekday - 1) < 7) ? (i + todayWeekday - 1): (i + todayWeekday - 8))
            ilabel.textAlignment = .Center
             print("sector: = \(ilabel.text)")
            
            if i == 0{ // highlight today on the wheel
                print("make today purple: \(i)")
                ilabel.textColor = UIColor.purpleColor()
            }
            
            ilabel.layer.anchorPoint = CGPointMake(1.0, 0.5)
             ilabel.layer.position = CGPointMake((container?.bounds.size.width)!/2, (container?.bounds.size.height)!/2)
            /*ilabel.layer.anchorPoint = CGPointMake(1/15, 1/6)
            ilabel.layer.position = CGPointMake((container?.bounds.size.width)!/2, (container?.bounds.size.height)!/2)
            ilabel.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI/2))
            */
            //ilabel.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI/2))
            //ilabel.transform = CGAffineTransformMakeTranslation(-(container?.bounds.size.width)!/2, 0)
            
            /*var t = CGAffineTransformIdentity
            t = CGAffineTransformTranslate(t, CGFloat(100), CGFloat(300))
            t = CGAffineTransformRotate(t, CGFloat(M_PI_4))
            t = CGAffineTransformScale(t, CGFloat(-1), CGFloat(2))
            // ... add as many as you want, then apply it to to the view
            imageView.transform = t*/
            ilabel.transform = CGAffineTransformMakeRotation(angleSize * CGFloat(i))
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
        bg.image = UIImage(named: "bg.png")
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

    //func wheelDidChangeValue(newValue: String) {
       // self.sectorLabel.text = newValue
    //}
    
    func rotate() -> Void {
        let t: CGAffineTransform = CGAffineTransformRotate(container!.transform, -0.78)
        container!.transform = t
    }
    
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
            
            if sector.minValue < Float(-M_PI){
                mid = -mid
                mid -= Float(fanWidth)
            }
            
            // 5 - Add sector to arry
            sectors.append(sector)
            print("cl is \(sector.description)")
            
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
            return "Sun"
        case 1:
            return "Mon"
        case 2:
            return "Tue"
        case 3:
            return "Wed"
        case 4:
            return "Thu"
        case 5:
            return "Fri"
        case 6:
            return "Sat"
        default:
            return "Sun"
        }
    }
    
    

    
    
   
}
