//
//  Canvas+Touch.swift
//  Canvas
//
//  Created by Adeola Uthman on 1/10/18.
//

import Foundation

public extension Canvas {
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // Get the last few touches.
        self.lastPoint = touch.previousLocation(in: self)
        self.lastLastPoint = touch.previousLocation(in: self)
        self.currentPoint = touch.location(in: self)
        
        // Retrieve the path up to this point (for the undo/redo function).
        undoRedoManager.undoStack.push(_path.mutableCopy()!)
        
        delegate?.didBeginDrawing(self)
    }
    
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // Get the last few touches.
        self.lastLastPoint = self.lastPoint
        self.lastPoint = touch.previousLocation(in: self)
        self.currentPoint = touch.location(in: self)
        
        // Get the midpoints between the touches, which will be used for the curve.
        let mid1 = midpoint(a: self.lastPoint, b: self.lastLastPoint)
        let mid2 = midpoint(a: self.currentPoint, b: self.lastPoint)
        
        // Create a subpath to draw.
        let subpath = CGMutablePath()
        subpath.move(to: mid1)
        subpath.addQuadCurve(to: mid2, control: self.lastPoint)
        
        // Only update the bounding box for improved performance.
        let bounds = subpath.boundingBox
        let drawBox = bounds.insetBy(dx: Constants.drawDistance * brush.thickness, dy: Constants.drawDistance * brush.thickness)
        
        // Clear the redo stack.
        undoRedoManager.redoStack.clear()
        
        // Add and close the path, then update.
        _path.addPath(subpath)
        subpath.closeSubpath()
        self.setNeedsDisplay(drawBox)
        
        delegate?.isDrawing(self)
    }
    
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.didEndDrawing(self)
    }
    
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.didEndDrawing(self)
    }
    
    
}
