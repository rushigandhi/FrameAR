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

class ARViewController: UIViewController, ARSCNViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var tableViewList:[String] = []
    
    var selectedProjectIndex: Int = -1
    var selectedCommit: Commit? = nil
    var branch: String = "master"
    var loadedSCNS = [URL]()


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell!
        
        // set the text from the data model
        cell.textLabel?.text = tableViewList[indexPath.row]
        
        return cell
    }
    

    @IBOutlet weak var drawer: UIView!
    @IBOutlet weak var drawerTitle: UILabel!
    
    var drawerOpen = false
    var plane_only = true 
    var currentAngleY: Float = 0.0

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func surfaceAirSegmentedControl(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            plane_only = true
            sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                
                if node.name == "air" {
                    node.removeFromParentNode()
                }
                else {
//                    node.isHidden = false
                }
            
            }
        }
            
        else {
            
            plane_only = false
            sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                
                if node.name == "surface" {
                    node.removeFromParentNode()
                }
                else {
//                    node.isHidden = true
                }
            }
        }
        
    }
    @IBAction func annotationButton(_ sender: Any) {
        if !drawerOpen {
            drawer.isHidden = false
            drawerTitle.text = "Comments"
            commentInputView.isHidden = false;
            tableViewList = selectedCommit!.comments
            tableView.reloadData()
        }
    }
    @IBAction func compareButton(_ sender: Any) {
        if !drawerOpen {
            drawer.isHidden = false
            drawerTitle.text = "Compare"
            commentInputView.isHidden = false;

        }
    }
    
    @IBAction func commitButton(_ sender: Any) {
        if !drawerOpen {
            drawer.isHidden = false
            drawerTitle.text = "Commits"
            commentInputView.isHidden = false;
            
            let project = DataManager.shared.projects[selectedProjectIndex]
            
            let commits = CommitCalculator.getCommitsOfBranch(project: project, branch: branch)
            
            tableViewList = commits.map{$0.message}
            tableView.reloadData()
        }
    }
    
    @IBAction func filesButton(_ sender: Any) {
        if !drawerOpen {
            drawer.isHidden = false
            drawerTitle.text = "Files"
            commentInputView.isHidden = false;
            tableViewList = selectedCommit!.files
            tableView.reloadData()
        }
    }
    
    
    @IBOutlet weak var commentInputView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !drawerOpen {
            drawer.isHidden = true
        }
        drawer.alpha = 0.8
        commentInputView.isHidden = true;
//        addAnnotation()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // (optional) include this line if you want to remove the extra empty cell divider lines
        // self.tableView.tableFooterView = UIView()
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
        
        tableViewList = DataManager.shared.projects.map{$0.name}
        
        let project = DataManager.shared.projects[selectedProjectIndex]
        
        let basePath = "http://192.168.137.1:8080/" + project.id + "/" + selectedCommit!.id + "/"
        
        for fileName in selectedCommit!.files {
            loadSCN(basePath + fileName)
        }
    }
    
    func loadSCN(_ fileUrl: String) {
        if let url = URL(string: fileUrl) {
            print(url)
            
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 10.0
            sessionConfig.timeoutIntervalForResource = 20.0
            let session = URLSession(configuration: sessionConfig)
            
            let request = URLRequest(url: url)
            
            let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                if(tempLocalUrl != nil) {
                    if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                        print("Successfully downloaded. Status code: \(statusCode)")
                    }
                    
                    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                    let documentsDirectory = paths[0]
                    
                    do {
                        try FileManager.default.createDirectory(atPath: documentsDirectory.path, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        print(error)
                    }
                    
                    let localUrl = documentsDirectory.appendingPathComponent(tempLocalUrl!.lastPathComponent)
                    
                    
                    let local_url = localUrl
                        .deletingPathExtension()
                        .appendingPathExtension("scn")
                    
                    try? FileManager.default.removeItem(at: local_url)
                    
                    do {
                        print(tempLocalUrl,local_url)
                        try FileManager.default.moveItem(at: tempLocalUrl!, to: local_url)
                        self.loadedSCNS.append(local_url)
                    } catch {
                        print("failed to copy item")
                        print(error)
                    }
                    
                } else {
                    print("Failed")
                }
            }
            
            task.resume()
        } else {
            print("No URL")
        }
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
        
        configureLighting()
        addTapGestureToSceneView()
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    // Anywhere in the air
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        drawerOpen = false
        drawer.isHidden = true
        
        if !plane_only {

            guard let touch = touches.first else { return }
            let result = sceneView.hitTest(touch.location(in: sceneView), types: [ARHitTestResult.ResultType.featurePoint])
            guard let hitResult = result.last else { return }
            let hitTransform = SCNMatrix4.init(hitResult.worldTransform)
            let hitVector = SCNVector3Make(hitTransform.m41, hitTransform.m42, hitTransform.m43)
            addObject(position: hitVector)
        }
    }
    
    func addObject(position: SCNVector3){
        
        print(loadedSCNS)
        if (!loadedSCNS.isEmpty){
            let object_path = loadedSCNS.randomElement()
            
            
            
            //        print(object_url)
            //        let object_path =  "art.scnassets/" + "model" + ".scn"
            do {
                print(object_path)
                let objectScene = try SCNScene.init(url: object_path!, options: nil)
                
                let objectNode = objectScene.rootNode.childNodes[0]
                let material = SCNMaterial()
                objectNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                objectNode.scale = SCNVector3(x: 0.00254, y: 0.00254, z: 0.00254)
                objectNode.eulerAngles = SCNVector3(x: 90, y: 90, z: 90)
                //        guard let objectScene = try? SCNScene(url: object_path),
                //            let objectNode = objectScene.rootNode.childNode(withName: object, recursively: false)
                //            else { return }
                
                objectNode.position = position
                
                //Lighting
                let spotLight = SCNLight()
                spotLight.type = SCNLight.LightType.probe
                spotLight.spotInnerAngle = 30.0
                spotLight.spotOuterAngle = 80.0
                spotLight.castsShadow = true
                objectNode.light = spotLight
                objectNode.name = "air"
                
                
                //Add max 1 object
                let childNodes = sceneView.scene.rootNode.childNodes
                if (childNodes.isEmpty){
                    sceneView.scene.rootNode.addChildNode(objectNode)
                } else{
                    sceneView.scene.rootNode.replaceChildNode(childNodes[0], with: objectNode)
                }
            } catch {
                print("failed to make obj scene")
                print(error)
            }
            
        }
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
    
    
    @objc func addModelToSceneViewSurface(withGestureRecognizer recognizer: UIGestureRecognizer) {
        
        drawerOpen = false
        drawer.isHidden = true
        
        if plane_only {
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
            print(loadedSCNS)
            if (!loadedSCNS.isEmpty){
                let object_path = loadedSCNS.randomElement()
                
                
                
                //        print(object_url)
                //        let object_path =  "art.scnassets/" + "model" + ".scn"
                do {
                    print(object_path)
                    let objectScene = try SCNScene.init(url: object_path!, options: nil)
                    
                    let objectNode = objectScene.rootNode.childNodes[0]
                    let material = SCNMaterial()
                    objectNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                    objectNode.scale = SCNVector3(x: 0.00254, y: 0.00254, z: 0.00254)
                    objectNode.eulerAngles = SCNVector3(x: 90, y: 90, z: 90)
                    //        guard let objectScene = try? SCNScene(url: object_path),
                    //            let objectNode = objectScene.rootNode.childNode(withName: object, recursively: false)
                    //            else { return }
                    
                    objectNode.position = SCNVector3(x,y,z)
                    
                    //Lighting
                    let spotLight = SCNLight()
                    spotLight.type = SCNLight.LightType.probe
                    spotLight.spotInnerAngle = 30.0
                    spotLight.spotOuterAngle = 80.0
                    spotLight.castsShadow = true
                    objectNode.light = spotLight
                    objectNode.name = "surface"
                    
                    
                    
                    //Add max 1 object
                    let childNodes = sceneView.scene.rootNode.childNodes
                    if (childNodes.isEmpty){
                        sceneView.scene.rootNode.addChildNode(objectNode)
                    } else{
                        sceneView.scene.rootNode.replaceChildNode(childNodes[0], with: objectNode)
                    }
                } catch {
                    print("failed to make obj scene")
                    print(error)
                }
                
            }
        }

    }
    
    func addTapGestureToSceneView() {
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(ARViewController.scaleObject(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(pinchGestureRecognizer)

        if plane_only {
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ARViewController.addModelToSceneViewSurface(withGestureRecognizer:)))
            sceneView.addGestureRecognizer(tapGestureRecognizer)
            
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

