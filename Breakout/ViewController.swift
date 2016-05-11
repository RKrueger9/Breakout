//
//  ViewController.swift
//  Breakout
//
//  Created by RKrueger on 2/26/16.
//  Copyright © 2016 RKrueger. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollisionBehaviorDelegate
{
    @IBOutlet weak var livesLabel: UILabel!
    
    var dynamicAnimator = UIDynamicAnimator();
    var paddle = UIView()
    var ball = UIView()
    var brick = UIView()
    var lives = 5;
    var collisionBehavior = UICollisionBehavior()
    var bricks : [UIView] = []
    var allObjects : [UIView] = []
    var allDynamicBehavoirs : [UIDynamicItemBehavior] = []
    var brickCount = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        resetGame()
    }
    
    func resetGame()
    {
        //makes a black ball object in the view
        ball = UIView(frame: CGRectMake(view.center.x, view.center.y, 20, 20))
        ball.backgroundColor = UIColor.blackColor();
        ball.layer.cornerRadius = 10
        ball.clipsToBounds = true
        allObjects.append(ball)
        view.addSubview(ball)
        
        //add a red paddle object to the view
        paddle = UIView(frame: CGRectMake(view.center.x, view.center.y * 1.7, 80, 20))
        paddle.backgroundColor = UIColor.redColor()
        allObjects.append(paddle)
        view.addSubview(paddle)
        
        //add rows of bricks to view
        addRows(40, color: UIColor.blueColor())
        addRows(70, color: UIColor.yellowColor())
        addRows(100, color: UIColor.purpleColor())
       
        
        dynamicAnimator = UIDynamicAnimator(referenceView: view)
        
        //create dynamic behavior for ball
        let ballDynamicBehavior = UIDynamicItemBehavior(items:[ball])
        ballDynamicBehavior.friction = 0
        ballDynamicBehavior.resistance = 0
        ballDynamicBehavior.elasticity = 1.0
        ballDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(ballDynamicBehavior)
        allDynamicBehavoirs.append(ballDynamicBehavior)
      
        
        //create dynamic behavior for ball
        let paddleDynamicBehavior = UIDynamicItemBehavior(items: [paddle])
        paddleDynamicBehavior.density = 10000
        paddleDynamicBehavior.resistance = 100
        paddleDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(paddleDynamicBehavior)
        allDynamicBehavoirs.append(paddleDynamicBehavior)
        
        //create dynamic behavior for brick
        let brickDynamicBehavior = UIDynamicItemBehavior(items: bricks)
        brickDynamicBehavior.density = 10000
        brickDynamicBehavior.resistance = 100
        brickDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(brickDynamicBehavior)
        allDynamicBehavoirs.append(brickDynamicBehavior)

        
        //creates a push behavoir to get the ball moving
        let pushBehavior = UIPushBehavior(items: [ball], mode: .Instantaneous)
        pushBehavior.pushDirection = CGVectorMake(0.2, 1.0)
        pushBehavior.magnitude = 0.25
        dynamicAnimator.addBehavior(pushBehavior)
        
        //create collision  behaviors the the ball can bounce off other objects
        collisionBehavior = UICollisionBehavior(items: allObjects)
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        collisionBehavior.collisionMode = .Everything
        collisionBehavior.collisionDelegate = self
        dynamicAnimator.addBehavior(collisionBehavior)
        
        livesLabel.text = "Lives: \(lives)"
    }
    
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
        
        if(item.isEqual(ball) && p.y > paddle.center.y)
        {
            lives--
            if(lives > 0)
            {
                livesLabel.text = "Lives: \(lives)"
                ball.center = view.center
                dynamicAnimator.updateItemUsingCurrentState(ball)
    
            }
            else
            {
                livesLabel.text = "Game Over"
                endGame()
                callLoseAlert()
            }
        }
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint)
    {
        for brick in bricks
        {
            if (item1.isEqual(ball) && item2.isEqual(brick) || item1.isEqual(brick) && item2.isEqual(ball))
            {
                if brick.backgroundColor == UIColor.blueColor()
                {
                    brick.backgroundColor = UIColor.yellowColor()
                }
                else if(brick.backgroundColor == UIColor.yellowColor())
                {
                    brick.backgroundColor = UIColor.purpleColor()
                }
                else
                {
                    collisionBehavior.removeItem(brick)
                    brick.hidden = true
                    checkGameOver()
                }
            }
        }
    }
    
    func addRows(z: CGFloat, color: UIColor)
    {
        let width = (Int)(view.bounds.size.width - 40)
        let xOffset = ((Int)(view.bounds.size.width) % 42 / 2)
        for var i = xOffset; i < width; i += 50
        {
            let x = CGFloat(i);
            addBlock(x, y: z, color: color)
        }
    }
    
    func endGame()
    {
        collisionBehavior.removeItem(ball)
        for all in allObjects
        {
            all.removeFromSuperview()
        }
        //empties arrays and resets other variables
        allObjects.removeAll()
        bricks.removeAll()
        brickCount = 0;
        lives = 5
    }
    
    func addBlock(x: CGFloat, y: CGFloat, color: UIColor)
    {
        brick = UIView(frame: CGRectMake(x, y, 40, 20))
        brick.backgroundColor = color
        bricks.append(brick)
        allObjects.append(brick)
        view.addSubview(brick)
    }
    
    func checkGameOver()
    {
        if(brick.hidden == true)
        {
            ++brickCount
            if(brickCount == bricks.count)
            {
                livesLabel.text = "You Win!"
                endGame()
                callWinAlert()
            }
        }
        
    }
    
    func callWinAlert()
    {
        let alert = UIAlertController(title: "You Win!", message: nil, preferredStyle: .Alert)
        let resetAction = UIAlertAction(title: "Play Again", style: .Default) { (action) -> Void in
            self.resetGame()
        }
        alert.addAction(resetAction)
        let quitAction = UIAlertAction(title: "Quit", style: .Default) { (action) -> Void in
            //
        }
        alert.addAction(quitAction)
        self.presentViewController(alert, animated: true, completion: nil);
    }
    
    func callLoseAlert()
    {
        let alert = UIAlertController(title: "You Lose!", message: nil, preferredStyle: .Alert)
        let resetAction = UIAlertAction(title: "Try Again", style: .Default) { (action) -> Void in
            self.resetGame()
        }
        alert.addAction(resetAction)
        let quitAction = UIAlertAction(title: "Rage quit", style: .Default) { (action) -> Void in
           //
        }
        alert.addAction(quitAction)
        self.presentViewController(alert, animated: true, completion: nil);

    }
    
    @IBAction func panGesture(sender: UIPanGestureRecognizer)
    {
        let panGesture = sender.locationInView(view)
        paddle.center = CGPointMake(panGesture.x, paddle.center.y)
        dynamicAnimator.updateItemUsingCurrentState(paddle)
    }
}





