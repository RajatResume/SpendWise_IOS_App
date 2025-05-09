// Team Members:
// - Venkatesh Talasila - vtalasi@iu.edu
// - Rajat Madhav Sawant - rsawant@iu.edu

// Final Project iOS App Name: SpendWise

// IU GitHub Submission Date: May 6, 2025

import SpriteKit

class CoinDropScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .white

        let coin = SKSpriteNode(imageNamed: "coin") // Add coin.png to Assets
        coin.size = CGSize(width: 60, height: 60)
        coin.position = CGPoint(x: frame.midX, y: frame.maxY)
        addChild(coin)

        let fallAction = SKAction.move(to: CGPoint(x: frame.midX, y: frame.minY + 60), duration: 1.2)
        let spin = SKAction.rotate(byAngle: .pi * 2, duration: 0.5)
        let group = SKAction.group([fallAction, SKAction.repeatForever(spin)])
        coin.run(group)

        // Remove after 2.5s
        run(SKAction.sequence([
            SKAction.wait(forDuration: 2.5),
            SKAction.run { self.view?.window?.rootViewController?.dismiss(animated: true) }
        ]))
    }
}
