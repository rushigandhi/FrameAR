//
//  ViewController.swift
//  app
//
//  Created by Rushi Gandhi on 2019-06-22.
//  Copyright © 2019 Rushi Gandhi. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ARViewController: UIViewController, ARSCNViewDelegate {

    var plane_only = false

    @IBOutlet var sceneView: ARSCNView!
    
    @IBAction func surfaceButton(_ sender: Any) {
        plane_only = true
    }
    
    @IBAction func annotationButton(_ sender: Any) {
    }
    
    @IBAction func airButton(_ sender: Any) {
        plane_only = false
    }
    @IBAction func compareButton(_ sender: Any) {
    }
    
    @IBAction func commitButton(_ sender: Any) {
    }
    

    @IBAction func filesButton(_ sender: Any) {
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLighting()
        addTapGestureToSceneView()
        addAnnotation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSceneView()
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
        sceneView.debugOptions = [.showFeaturePoints]
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        plane.materials.first?.diffuse.contents = UIColor.transparentLightBlue
        
        let planeNode = SCNNode(geometry: plane)
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
    }
    
    func getObject() -> String {
        let objects = ["ship","plant", "model", "gaychair"]
        let object = objects.randomElement() ?? "model"
        return (object)
    }
    
    @objc func addObject(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        var hitTestResults = sceneView.hitTest(tapLocation, types: [.featurePoint,.existingPlaneUsingExtent])
        if (plane_only){
            hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        }
        
        
        guard let hitTestResult = hitTestResults.first else { return }
        let translation = hitTestResult.worldTransform.translation
        let x = translation.x
        let y = translation.y
        let z = translation.z
        let object = getObject()
        print(object)
        let object_path =  "art.scnassets/" + object + ".scn"
        guard let objectScene = SCNScene(named: object_path),
            let objectNode = objectScene.rootNode.childNode(withName: object, recursively: false)
            else { return }
        
        objectNode.position = SCNVector3(x,y,z)
        
        //Lighting
        let spotLight = SCNLight()
        spotLight.type = SCNLight.LightType.probe
        spotLight.spotInnerAngle = 30.0
        spotLight.spotOuterAngle = 80.0
        spotLight.castsShadow = true
        objectNode.light = spotLight
        
        //Rotation
        let obj_rotate = SCNAction.rotateBy(x:0, y: 2 * .pi, z: 0, duration: 30)
        let repeatRotate = SCNAction.repeatForever(obj_rotate)
        objectNode.runAction(repeatRotate)
        
        //Add max 1 object
        let childNodes = sceneView.scene.rootNode.childNodes
        if (childNodes.isEmpty){
            sceneView.scene.rootNode.addChildNode(objectNode)
        } else{
            sceneView.scene.rootNode.replaceChildNode(childNodes[0], with: objectNode)
        }
        
    }
    
    
    @objc func scaleObject(withGestureRecognizer gesture: UIPinchGestureRecognizer) {
        let childNodes = sceneView.scene.rootNode.childNodes
        let curNode = childNodes[0]
        let nodeToScale = curNode
        if gesture.state == .changed {
            
            let pinchScaleX: CGFloat = gesture.scale * CGFloat((nodeToScale.scale.x))
            let pinchScaleY: CGFloat = gesture.scale * CGFloat((nodeToScale.scale.y))
            let pinchScaleZ: CGFloat = gesture.scale * CGFloat((nodeToScale.scale.z))
            nodeToScale.scale = SCNVector3Make(Float(pinchScaleX), Float(pinchScaleY), Float(pinchScaleZ))
            gesture.scale = 1
            
        }
        if gesture.state == .ended { }
        
    }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ARViewController.addObject(withGestureRecognizer:)))
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(ARViewController.scaleObject(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(pinchGestureRecognizer)
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    let textNode = SCNNode()
    
    func addAnnotation() {
        let childNodes = sceneView.scene.rootNode.childNodes
        let curNode = childNodes[0]
        let comment = "sex"
        let text = SCNText(string: comment, extrusionDepth: 1)
        text.font = UIFont(name: "futura", size:50)
        let scale = 0.1 / text.font.pointSize
        
        textNode.scale = SCNVector3(scale,scale,scale)
        textNode.geometry = text
        curNode.addChildNode(textNode)
        let max = textNode.boundingBox.max.x
        let min = textNode.boundingBox.min.x
        let midpoint = -((max-min)/2 + min) * Float(scale)
        textNode.position = SCNVector3(midpoint,0.35,0)
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
        return UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.50)
    }
}

