Strict
#rem
	Ported to Monkey By SKN3 Ltd from https://github.com/mb1/VRope
	
	MIT License.
	http://opensource.org/licenses/MIT
	
	Copyright (c) 2012 SKN3
	Copyright (c) 2012 Flightless Ltd.
	Copyright (c) 2010 Clever Hamster Games.
	
	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
	documentation files (the "Software"), to deal in the Software without restriction, including without limitation 
	the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
	and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in all copies or substantial portions 
	of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
	TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
	THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
	CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
	DEALINGS IN THE SOFTWARE.
#end

Import monkey.math

Class VRope
	Field PTM_RATIO:Int = 32
	Field numPoints:int
	Field points:VPoint[]
	Field sticks:VStick[]
	Field antiSagHack:float = 0.2 'HACK: scale down rope points to cheat sag. set to 0 to disable, max suggested value 0.1
	Field iterations:Int = 4
	Field x1:Float
	Field y1:Float
	Field x2:Float
	Field y2:Float
	
	Method New(x1:Float, y1:Float, x2:Float, y2:Float, segments:Int = 20)
		' --- create the new vrope ---
		Local index:Int
		
		'get distance between the two points
		Local distance:= Sqrt( (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))

		'set number of points
		numPoints = (distance / (distance / segments)) + 1'add 1 to takeinto account end point 
		
		'setup difference values for plotting points
		Local diffVectorX:= x2 - x1
		Local diffVectorY:= y2 - y1
		Local multiplier:= distance / (numPoints - 1)
		Local ccpLength:Float = Sqrt( (diffVectorX * diffVectorX) + (diffVectorY * diffVectorY))
		
		'create vpoints
		points = New VPoint[numPoints]
		For index = 0 Until points.Length
			points[index] = New VPoint(x1 + (diffVectorX * (1.0 / ccpLength)) * (multiplier * index * (1 - antiSagHack)), y1 + (diffVectorY * (1.0 / ccpLength)) * (multiplier * index * (1 - antiSagHack)))
		Next
		
		'create vsticks
		sticks = New VStick[numPoints - 1]
		For index = 0 Until sticks.Length
			sticks[index] = New VStick(points[index], points[index + 1])
		Next
	End

	Method Rebuild:Void(x1:Float, y1:Float, x2:Float, y2:Float)
		' --- reset all the points in the rope with a new start and end ---
		Local index:Int
		
		'get distance between the two points
		Local distance:= Sqrt( (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
		
		'setup difference values for plotting points
		Local diffVectorX:= x2 - x1
		Local diffVectorY:= y2 - y1
		Local multiplier:= distance / (numPoints - 1)
		Local ccpLength:Float = Sqrt( (diffVectorX * diffVectorX) + (diffVectorY * diffVectorY))
		
		'modify all points
		For index = 0 Until points.Length
			points[index].SetPos(x1 + (diffVectorX * (1.0 / ccpLength)) * (multiplier * index * (1 - antiSagHack)), y1 + (diffVectorY * (1.0 / ccpLength)) * (multiplier * index * (1 - antiSagHack)))
		Next
	End

	Method Update:Void(delta:Float, x1:Float, y1:Float, x2:Float, y2:Float)
		' --- update the rope with start and end points ---
		Local index:Int
		
		'all points need to have gravity applied
		For index = 0 To points.Length - 1
			points[index].ApplyGravity(delta)
			points[index].Update()
		Next
		
		'contract sticks
		For Local iteration:= 0 Until iterations
			For index = 0 Until points.Length - 1
				sticks[index].Contract()
			Next
		Next
		
		'manually set position for first and last point of rope (to lock anchors)
		points[0].SetPos(x1, y1)
		points[numPoints - 1].SetPos(x2, y2)
	End
	
	Method Advance:Void(dt:Float, fps:Int)
		' --- advance the simulation ---
		Local counter:= dt * fps
		Local counterStep:= 1.0 / fps
		While counter > 0
			counter -= counterStep
			Update(counterStep, points[0].x, points[0].y, points[points.Length - 1].x, points[points.Length - 1].y)
		Wend
	End
End

Class VStick
	Field pointA:VPoint
	Field pointB:VPoint
	Field hypotenuse:Float
	
	Method New(pointA:VPoint, pointB:VPoint)
		Self.pointA = pointA
		Self.pointB = pointB
		hypotenuse = Sqrt( (pointB.x - pointA.x) * (pointB.x - pointA.x) + (pointB.y - pointA.y) * (pointB.y - pointA.y))
	End

	Method Contract:Void()
		Local dx:float = pointB.x - pointA.x
		Local dy:float = pointB.y - pointA.y
		Local h:Float = Sqrt( (pointB.x - pointA.x) * (pointB.x - pointA.x) + (pointB.y - pointA.y) * (pointB.y - pointA.y))
		
		Local diff:float = hypotenuse - h
		Local offx:float = (diff * dx / h) * 0.5
		Local offy:float = (diff * dy / h) * 0.5
		pointA.x -= offx
		pointA.y -= offy
		pointB.x += offx
		pointB.y += offy
	End
End

Class VPoint
	Field x:Float
	Field y:Float
	Field oldX:Float
	Field oldY:Float
	Field gravityX:= 0.0
	Field gravityY:= 9.8

	Method New(x:Float, y:Float)
		Self.x = x
		Self.y = y
		Self.oldX = x
		Self.oldY = y
	End
	
	Method SetPos:Void(x:Float, y:Float)
		Self.x = x
		Self.y = y
		Self.oldX = x
		Self.oldY = y
	End

	Method Update:Void()
		Local tempX:Float = x
		Local tempY:Float = y
		x += x - oldX
		y += y - oldY
		oldX = tempX
		oldY = tempY
	End

	Method ApplyGravity:Void(dt:float)
		x += gravityX * dt
		y += gravityY * dt
	End
	
	Method ApplyGravity:Void(gravityX:float, gravityY:float)
		x += gravityX
		y += gravityY
	End
End