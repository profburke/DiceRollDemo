//
//  GameViewController.swift
//  DiceRollDemo
//
//  Created by Matthew Burke on 10/7/21.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    private var scnView: SCNView!
    private var scnScene: SCNScene!
    private var cameraNode: SCNNode!
    private var diceNodes: [SCNNode] = []
    private var speeds: [SCNVector3] = []

    func setupView() {
        scnView = view as? SCNView
        scnView.autoenablesDefaultLighting = true
        scnView.delegate = self
        scnView.isPlaying = true

        scnView.backgroundColor = .blue
    }

    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()

        cameraNode.position = SCNVector3(x: 0, y: 20, z:2)
        cameraNode.rotation = SCNVector4(1, 0, 0, -Float.pi/2)

        scnScene.rootNode.addChildNode(cameraNode)
    }

    func setupLight() {
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scnScene.rootNode.addChildNode(lightNode)

        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scnScene.rootNode.addChildNode(ambientLightNode)
    }

    func setupScene() {
        scnScene = SCNScene()
        scnScene.background.contents = UIImage(named: "Grain")
        scnView.scene = scnScene
        setupCamera()
        setupLight()

        scnScene.physicsWorld.speed = 3

        let sides = [
            UIImage(named: "Image1")!,
            UIImage(named: "Image2")!,
            UIImage(named: "Image3")!,
            UIImage(named: "Image4")!,
            UIImage(named: "Image5")!,
            UIImage(named: "Image6")!,
        ]

        diceNodes.append(createDie(position: SCNVector3(-4, 0, 0), sides: sides))
        diceNodes.append(createDie(position: SCNVector3(4, 0, 0), sides: sides))
        diceNodes.append(createDie(position: SCNVector3(0, 0, 0), sides: sides))

        speeds.append(SCNVector3(0, 0, 0))
        speeds.append(SCNVector3(0, 0, 0))
        speeds.append(SCNVector3(0, 0, 0))

        let torque = SCNVector4(1, 2, -1, 1)
        for die in diceNodes {
            die.physicsBody?.applyTorque(torque, asImpulse: true)
            scnScene.rootNode.addChildNode(die)
        }

        var panel = wall(at: SCNVector3(0, 12, 0), with: SCNVector3Make(0, -1, 0), sized: CGSize(width: 50.0, height: 50.0)) // ceiling
        scnScene.rootNode.addChildNode(panel)
        panel = wall(at: SCNVector3(0, -8, 0), with: SCNVector3Make(0, 1, 0), sized: CGSize(width: 50.0, height: 50.0)) // floor
        scnScene.rootNode.addChildNode(panel)
        panel = wall(at: SCNVector3(10, -8, 0), with: SCNVector3Make(-1, 0, 0), sized: CGSize(width: 50.0, height: 50.0))
        scnScene.rootNode.addChildNode(panel)
        panel = wall(at: SCNVector3(-10, -8, 0), with: SCNVector3Make(1, 0, 0), sized: CGSize(width: 50.0, height: 50.0))
        scnScene.rootNode.addChildNode(panel)
        panel = wall(at: SCNVector3(0, -8, 15), with: SCNVector3Make(0, 0, -1), sized: CGSize(width: 50.0, height: 50.0))
        scnScene.rootNode.addChildNode(panel)
        panel = wall(at: SCNVector3(0, -8, -15), with: SCNVector3Make(0, 0, 1), sized: CGSize(width: 50.0, height: 50.0))
        scnScene.rootNode.addChildNode(panel)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupScene()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    func setTorque() -> SCNVector4 {
        return SCNVector4(2, 4, -2, 2)
    }

    func setForce() -> SCNVector3 {
        return SCNVector3(1, 24, 2)
    }

    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        scnScene.physicsWorld.speed = 3.0
        let torque = setTorque()
        let force = setForce()

        for die in diceNodes {
            die.physicsBody?.applyTorque(torque, asImpulse: true)
            die.physicsBody?.applyForce(force, asImpulse: true)
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
}

extension SCNVector3 {
    var isZero: Bool {
        return self.x == 0.0 && self.y == 0.0 && self.z == 0.0
    }
}

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        for (num, die) in diceNodes.enumerated() {
            if let pb = die.physicsBody {
                let os = speeds[num]
                if !os.isZero && pb.velocity.isZero {
                    print("Die \(num) - Up index: \(boxUpIndex(n: die.presentation))")
                }
                speeds[num] = pb.velocity
            }
        }
    }
}
