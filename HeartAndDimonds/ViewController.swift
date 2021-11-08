//
//  ViewController.swift
//  HeartAndDimonds
//
//  Created by devadmin on 14.10.21.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet var sceneView: ARSCNView!
    
    var heartNode: SCNNode?
    var diamondNode: SCNNode?
    var imageNode = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblName.isHidden = false
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        let heartScene = SCNScene(named: "art.scnassets/heart.scn")
        let diamondScene = SCNScene(named: "art.scnassets/diamond.scn")
        heartNode = heartScene?.rootNode
        diamondNode = diamondScene?.rootNode
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARImageTrackingConfiguration()
        
        if let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "Playing Cards", bundle: Bundle.main) {
            configuration.trackingImages = trackingImages
            configuration.maximumNumberOfTrackedImages = 2
        }
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        DispatchQueue.main.async {
            self.lblName.isHidden = false
        }
        
        if let imageAnchor = anchor as? ARImageAnchor {
            let size = imageAnchor.referenceImage.physicalSize
            let plane = SCNPlane(width: size.width, height: size.height)
            plane.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.7)
            plane.cornerRadius = 0.005
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            node.addChildNode(planeNode)
            
            var shapeNode: SCNNode?
            if imageAnchor.referenceImage.name == "king" {
                shapeNode = heartNode
            } else {
                shapeNode = diamondNode
            }
            
            let shapeSpin = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 10)
            let repeatSpin = SCNAction.repeatForever(shapeSpin)
            shapeNode?.runAction(repeatSpin)
            
            guard let shape = shapeNode else {
                return nil
            }
            node.addChildNode(shape)
            imageNode.append(node)
            return node
        }
       return nil
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if imageNode.count == 2 {
            if imageNode[0].name == "king" {
                DispatchQueue.main.async {
                    self.lblName.text = self.imageNode[0].name
                }
            } else {
                DispatchQueue.main.async {
                     DispatchQueue.main.async {
                        self.lblName.text = self.imageNode[0].name
                    }
                }
            }
            let positionOne = SCNVector3ToGLKVector3(imageNode[0].position)
            let positionTwo = SCNVector3ToGLKVector3(imageNode[1].position)
            let distance = GLKVector3Distance(positionOne, positionTwo)
            
            if distance < 0.10 {
                spinJump(node: imageNode[0])
                spinJump(node: imageNode[1])
            }
            
        }
    }
    
    func spinJump(node: SCNNode) {
        print("name = \(node.childNodes[1].name)")
        let shapeNode = node.childNodes[1]
        let shapeSpin = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 1)
        shapeSpin.timingMode = .easeInEaseOut
        
        let up = SCNAction.moveBy(x: 0, y: 0.03, z: 0, duration: 0.5)
        up.timingMode = .easeInEaseOut
        let down = up.reversed()
        let upDown =  SCNAction.sequence([up,down])
        
        shapeNode.runAction(shapeSpin)
        shapeNode.runAction(upDown)
        
    }

}
