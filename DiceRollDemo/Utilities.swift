//
//  Utilities.swift
//  DiceRollDemo
//
//  Created by Matthew Burke on 10/7/21.
//

import Foundation
import SceneKit

// You'd think there would be an easier way to move a plane...
// this function adapted from
// https://stackoverflow.com/questions/47948345/scenekit-plane-rotation
func reposition(_ node: SCNNode, to position: SCNVector3, with normal: SCNVector3) {
    let transVector1 = SCNVector3Make(1,0,0)
    let transVector2 = SCNVector3Make(0,1,0)
    var tangent0 = SCNVector3CrossProduct(left: normal, right: transVector1)

    let dotprod = SCNVector3DotProduct(left: tangent0, right: tangent0)
    if dotprod < 0.001 {
        tangent0 = SCNVector3CrossProduct(left: normal, right: transVector2)
    }
    tangent0 = SCNVector3Normalize(vector: tangent0)

    let helpVector1 = SCNVector3CrossProduct(left: normal, right: tangent0)
    let tangent1 = SCNVector3Normalize(vector: helpVector1)

    let tangent0GLK = GLKVector4Make(tangent0.x, tangent0.y, tangent0.z, 0)
    let tangent1GLK = GLKVector4Make(tangent1.x, tangent1.y, tangent1.z, 0)
    let normalGLK = GLKVector4Make(normal.x, normal.y, normal.z, 0);

    let rotMat = GLKMatrix4MakeWithColumns(tangent0GLK, tangent1GLK, normalGLK, GLKVector4Make(0, 0, 0, 1))
    // transforms the "normal position" of the plane
    let transMat = SCNMatrix4MakeTranslation(node.position.x, node.position.y, node.position.z);

    node.transform = SCNMatrix4Mult(transMat, SCNMatrix4FromGLKMatrix4(rotMat))

    // position must be set again!
    node.position = position
}

func wall(at position: SCNVector3, with normal: SCNVector3, sized size: CGSize, color: UIColor = .clear) -> SCNNode {
    let geometry = SCNPlane(width: size.width, height: size.height)
    geometry.materials.first?.diffuse.contents = color
    geometry.materials.first?.isDoubleSided = true

    let geometryNode = SCNNode(geometry: geometry)
    geometryNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)

    geometryNode.position = position

    reposition(geometryNode, to: position, with: normal)

    return geometryNode
}

func createDie(position: SCNVector3, sides: [UIImage]) -> SCNNode {
    let geometry = SCNBox(width: 3.0, height: 3.0, length: 3.0, chamferRadius: 0.1)

    let material1 = SCNMaterial()
    material1.diffuse.contents = sides[0]
    let material2 = SCNMaterial()
    material2.diffuse.contents = sides[1]
    let material3 = SCNMaterial()
    material3.diffuse.contents = sides[2]
    let material4 = SCNMaterial()
    material4.diffuse.contents = sides[3]
    let material5 = SCNMaterial()
    material5.diffuse.contents = sides[4]
    let material6 = SCNMaterial()
    material6.diffuse.contents = sides[5]

    geometry.materials = [material1, material2, material3, material4, material5, material6]

    let node = SCNNode(geometry: geometry)
    node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
    node.position = position

    return node
}


func SCNVector3CrossProduct(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.y * right.z - left.z * right.y, left.z * right.x - left.x * right.z, left.x * right.y - left.y * right.x)
}

func SCNVector3DotProduct(left: SCNVector3, right: SCNVector3) -> float_t {
    return (left.x * right.x + left.y * right.y + left.z * right.z)
}

func SCNVector3Normalize(vector: SCNVector3) -> SCNVector3 {
    let scale = 1.0 / sqrt(vector.x*vector.x + vector.y*vector.y + vector.z*vector.z)

    return SCNVector3Make(vector.x * scale, vector.y * scale, vector.z*scale)
}
