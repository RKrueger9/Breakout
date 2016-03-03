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
    var lives = 100;
    var collisionBehavior = UICollisionBehavior()
    var bricks : [UIView] = []
    var allObjects : [UIView] = []
    var allHidden = false
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
        
        //add brick to view
        
        addBlock(20, y: 40, color: UIColor.blueColor())
        addBlock(80, y: 40, color: UIColor.blueColor())
        addBlock(20, y: 80, color: UIColor.yellowColor())
        
        dynamicAnimator = UIDynamicAnimator(referenceView: view)
        
        //create dynamic behavior for ball
        let ballDynamicBehavior = UIDynamicItemBehavior(items:[ball])
        ballDynamicBehavior.friction = 0
        ballDynamicBehavior.resistance = 0
        ballDynamicBehavior.elasticity = 1.0
        ballDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(ballDynamicBehavior)
        
        //create dynamic behavior for ball
        let paddleDynamicBehavior = UIDynamicItemBehavior(items: [paddle])
        paddleDynamicBehavior.density = 10000
        paddleDynamicBehavior.resistance = 100
        paddleDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(paddleDynamicBehavior)
        
        
        
        //create dynamic behavior for brick
        let brickDynamicBehavior = UIDynamicItemBehavior(items: bricks)
        brickDynamicBehavior.density = 10000
        brickDynamicBehavior.resistance = 100
        brickDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(brickDynamicBehavior)
        
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
            }
        }
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint)
    {
        if (item1.isEqual(ball) && item2.isEqual(brick) || item1.isEqual(brick) && item2.isEqual(paddle))
        {
            if brick.backgroundColor == UIColor.blueColor()
            {
                brick.backgroundColor = UIColor.yellowColor()
            }
            else
            {
                collisionBehavior.removeItem(brick)
                brick.hidden = true
                checkBricksHidden()
                if(allHidden == true)
                {
                    livesLabel.text = "You Won"
                    endGame()
                }
            }
        }
    }
    
    func endGame()
    {
        collisionBehavior.removeItem(ball)
        for all in allObjects
        {
            all.removeFromSuperview()
        }

    }
    
    func addBlock(x: CGFloat, y: CGFloat, color: UIColor)
    {
        brick = UIView(frame: CGRectMake(x, y, 40, 20))
        brick.backgroundColor = color
        bricks.append(brick)
        allObjects.append(brick)
        view.addSubview(brick)
    }
    
    func checkBricksHidden()
    {
        for brick in bricks
        {
            if(brick.hidden == true)
            {
                brickCount++
                if(brickCount == bricks.count)
                {
                    allHidden = true
                }
            }
        }
    }
    
    @IBAction func panGesture(sender: UIPanGestureRecognizer)
    {
        let panGesture = sender.locationInView(view)
        paddle.center = CGPointMake(panGesture.x, paddle.center.y)
        dynamicAnimator.updateItemUsingCurrentState(paddle)
    }
    
    
}





