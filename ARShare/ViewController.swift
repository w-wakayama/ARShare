//
//  ViewController.swift
//  ARShare
//
//  Created by 若山広大 on 2018/06/21.
//  Copyright © 2018年 若山広大. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

var boxNode = SCNNode()
let scene = SCNScene()
var flagYZ: Bool = true

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var planes = Array<Plane>()
    
    @IBAction func onPinchGesture(_ sender: UIPinchGestureRecognizer) {
        print(sender.scale)
        let pinchScaleX:CGFloat = ((sender.scale - 1.0) * 0.1 + 1.0) * CGFloat((boxNode.scale.x))
        let pinchScaleY:CGFloat = ((sender.scale - 1.0) * 0.1 + 1.0) * CGFloat((boxNode.scale.y))
        let pinchScaleZ:CGFloat = ((sender.scale - 1.0) * 0.1 + 1.0) * CGFloat((boxNode.scale.z))
        boxNode.scale = SCNVector3Make(Float(pinchScaleX), Float(pinchScaleY), Float(pinchScaleZ))
    }
    
    @IBAction func onPanGesture(_ sender: UIPanGestureRecognizer) {
        let point: CGPoint = sender.translation(in: sceneView)
        /*
        sender.view!.center.x += point.x
        sender.view!.center.y += point.y
        sender.setTranslation(CGPoint(x: 0, y: 0), in: sceneView)
        */
        if flagYZ == true {
            let panPositionX: CGFloat = point.x * 0.001 // * CGFloat((boxNode.position.x))
            let panPositionY: CGFloat = point.y * 0.001 // * CGFloat((boxNode.position.y))
            boxNode.position = SCNVector3Make(Float(panPositionX), Float(-panPositionY), Float(boxNode.position.z))
        } else {
            let panPositionX: CGFloat = point.x * 0.001 // * CGFloat((boxNode.position.x))
            let panPositionZ: CGFloat = point.y * 0.001 // * CGFloat((boxNode.position.z))
            boxNode.position = SCNVector3Make(Float(panPositionX), Float(boxNode.position.y), Float(panPositionZ))
        }
    }
    
    @IBAction func tapButtonZ(_ sender: UIButton) {
        flagYZ = !flagYZ
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        // let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // 箱を生成
        let boxGeometry = SCNBox(width: 0.1,
                                 height: 0.1,
                                 length: 0.1,
                                 chamferRadius: 0)
        boxNode = SCNNode(geometry: boxGeometry)
        boxNode.position = SCNVector3Make(0.1, 0.1, -0.1)
        scene.rootNode.addChildNode(boxNode)
        
        //sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
    /*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
    */
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // 平面を生成
        let plane = Plane(anchor: planeAnchor)
        
        // ノードを追加
        node.addChildNode(plane)
        
        // 管理用配列に追加
        planes.append(plane)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // updateされた平面ノードと同じidのものの情報をアップデート
        for plane in planes {
            if plane.anchor.identifier == anchor.identifier,
                let planeAnchor = anchor as? ARPlaneAnchor {
                plane.update(anchor: planeAnchor)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        // updateされた平面ノードと同じidのものの情報を削除
        for (index, plane) in planes.enumerated().reversed() {
            if plane.anchor.identifier == anchor.identifier {
                planes.remove(at: index)
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
