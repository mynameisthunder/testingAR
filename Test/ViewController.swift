//
//  ViewController.swift
//  testing out shit
//
//  Created by Omari Powell on 6/27/18.
//  Copyright © 2018 Omari Powell. All rights reserved.
//  Detects plane so we can get the y essentially for the floor/road but more importantly tests out
//  animations - its mad simple.
//  Also does the final test of putting something in real life at a coordinate and seeing that in
//  real life
// Also gets it to respond to gestures

import UIKit
import ARKit
import CoreLocation

class ViewController: UIViewController {
    @IBOutlet weak var sceneView: ARSCNView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        addBox()
        addTapGestureToSceneView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSceneView()
        configureLighting()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func setUpSceneView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    /*
     The maximum corner radius is half the box’s smallest dimension. For example, if a box’s width and length are both 5.0 and its height is 10.0, its maximum corner radius is 2.5. With these dimensions, the box’s four rounded vertical edges join to form a cylinder and its vertical faces disappear. Increasing the corner radius beyond the maximum has no visible effect.
    */
    func addBox(x: Float = 0, y: Float = 0, z: Float = -0.2) {
        let box = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
        
        let boxNode = SCNNode()
        boxNode.geometry = box
        boxNode.position = SCNVector3(x, y, z)
        boxNode.castsShadow = true
        //boxNode.geometry?.firstMaterial?.fillMode = .lines
        // - x is left, -y is down , +z is backwards
        box.firstMaterial?.diffuse.contents  = UIColor(red: 230.0 / 255.0, green: 15.0 / 255.0, blue: 130.0 / 255.0, alpha: 0.9)
        //box.firstMaterial?.isDoubleSided = true
        
        sceneView.scene.rootNode.addChildNode(boxNode)
    }

    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTap(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation)
        guard let node = hitTestResults.first?.node else {
            let hitTestResultsWithFeaturePoints = sceneView.hitTest(tapLocation, types: .featurePoint)
            if let hitTestResultWithFeaturePoints = hitTestResultsWithFeaturePoints.first {
                let translation = hitTestResultWithFeaturePoints.worldTransform.translation
                addBox(x: translation.x, y: translation.y, z: translation.z)
            }
            return
        }
        fadeDown(node, 4)
        //node.removeFromParentNode()
        // x y z
        node.scale = vectorMult(node.scale, 2)
    }
    
    func fadeDown(_ node: SCNNode, _ time: Float) {
        SCNTransaction.animationDuration = 1.0
        node.position.y = node.position.y - 0.1
        node.opacity = 0.2
        
    }
    
   
    
    func vectorMult(_ v: SCNVector3, _ scale: Float)-> SCNVector3{
        var newVector = SCNVector3()
        newVector.x = v.x * 2
        newVector.y = v.y * 2
        newVector.z = v.z * 2
        return newVector
    }
  
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // make sure u got it
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
    
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        
        plane.materials.first?.diffuse.contents = UIColor.transparentLightBlue
        
        // 4
        let planeNode = SCNNode(geometry: plane)
        
        // 5
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // 1
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        // Update the plane’s width and height using the planeAnchor extent’s x and z properties.
        // extent is the estimated width and length of the detected plane.
        let width = CGFloat(planeAnchor.extent.x)
        plane.width = width
        let height = CGFloat(planeAnchor.extent.z)
        plane.height = height
        // 3
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

extension UIColor {
    open class var transparentLightBlue: UIColor {
        return UIColor(red: 2-0/255, green: 19/255, blue: 250/255, alpha: 0.320)
    }
}
