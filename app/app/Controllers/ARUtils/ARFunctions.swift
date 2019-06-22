//
//  ARFunctions.swift
//  app
//
//  Created by Rafit Jamil on 2019-06-22.
//  Copyright © 2019 Rushi Gandhi. All rights reserved.
//

import Foundation

var currentAngleY: Float = 0.0

func rotateNode(_ gesture: UIRotationGestureRecognizer){
    let childNodes = sceneView.scene.rootNode.childNodes
    let curNode = childNodes[0]
    
    let rotation = Float(gesture.rotation)
    
    if gesture.state == .changed{
        
        curNode.eulerAngles.y = currentAngleY + rotation
    }
    
    if(gesture.state == .ended) {
        currentAngleY = curNode.eulerAngles.y
    }
}

func changeColor(_ objectNode: SCNNode,_ color: UIColor){
    // Un-share the geometry by copying
    objectNode.geometry = objectNode.geometry!.copy() as? SCNGeometry
    // Un-share the material, too
    objectNode.geometry?.firstMaterial = objectNode.geometry?.firstMaterial!.copy() as? SCNMaterial
    // Now, we can change node's material without changing parent and other childs:
    objectNode.geometry?.firstMaterial?.diffuse.contents = color
}
func makeNode (_ filepath: String) {
    guard let objectScene = SCNScene(named: filepath),
        let objectNode = objectScene.rootNode.childNode(withName: object, recursively: false)
        else { return }
    return objectNode
}
func frameDiff(_ oldFrame: String, newFrame: String){

    oldFrameNode = makeNode(oldFrame)
    newFrameNode = makeNode(newFrame)

    oldFrameNode.position = SCNVector3(x,y,z)
    newFrameNode.position = SCNVector3(x,y,z)
    
    oldFrameNode = changeColor(oldFrameNode, red)
    newFrameNode = changeColor(node1, green)

    
    sceneView.scene.rootNode.addChildNode(oldFrameNode)
    sceneView.scene.rootNode.addChildNode(newFrameNode)

}
