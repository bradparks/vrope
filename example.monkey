Import mojo
Import skn3.vrope

Function Main:Int()
	New Demo
End

Class Demo Extends App
	Field timestamp:Int
	Field timestampLast:Int
	
	Field delta:float
	Field deltaMillisecs:Int
	
	Field mouseX:Float
	Field mouseY:float
	
	Field rope:VRope
	
	Method OnCreate()
		' --- app is created ---
		SetUpdateRate(60)

		'create teh vrope
		rope = New VRope(100, 100, 140, 100, 16)
		rope.Advance(10.0, 60)
	End Method
	
	Method OnUpdate()
		' --- app is updated ---
		'update timestamp
		timestamp = Millisecs()
		
		'figure out delta ms
		If timestampLast = 0
			deltaMillisecs = timestamp
		Else
			deltaMillisecs = timestamp - timestampLast
		EndIf
		
		'figure out delta
		delta = (1.0 / 1000) * deltaMillisecs
		
		'update rope
		If MouseDown(MOUSE_LEFT)
			'update mouse/touch (take into account screen scale)
			mouseX = MouseX()
			mouseY = MouseY()
		EndIf
		
		rope.Update(delta, 100, 100, mouseX, mouseY)
		rope.Update(delta, 100, 100, mouseX, mouseY)
		
		'update end
		timestampLast = timestamp
	End Method
	
	Method OnRender()
		' --- app is rendered ---
		Cls(0, 0, 0)
		'render the rope
		SetColor(255, 0, 0)
		For Local index:= 0 Until rope.sticks.Length
			DrawLine(rope.sticks[index].pointA.x, rope.sticks[index].pointA.y, rope.sticks[index].pointB.x, rope.sticks[index].pointB.y)
		Next
	End Method
End