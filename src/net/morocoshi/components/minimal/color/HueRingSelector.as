package net.morocoshi.components.minimal.color 
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class HueRingSelector extends Sprite
	{
		private var dragKnob:Sprite;
		private var hueRing:HueRing;
		private var isMouseDown:Boolean;
		private var stageLocal:Stage;
		private var lastMouseAngle:Number;
		private var lastKnobAngle:Number;
		private var radius:Number;
		private var thickness:Number;
		private var _hue:Number = 0;
		
		public function HueRingSelector(radius:Number, thickness:Number) 
		{
			this.radius = radius;
			this.thickness = thickness;
			isMouseDown = true;
			dragKnob = createKnob(thickness * 0.5);
			dragKnob.addEventListener(MouseEvent.MOUSE_DOWN, knob_mouseDownHandler);
			setKnobAngle(0);
			hueRing = new HueRing(radius, thickness, 1);
			
			addChild(hueRing);
			addChild(dragKnob);
		}
		
		private function createKnob(radius:Number):Sprite 
		{
			var knob:Sprite = new Sprite();
			knob.graphics.beginFill(0x444444, 1);
			knob.graphics.drawCircle(0, 0, radius);
			knob.graphics.beginFill(0xf0f0f0, 1);
			knob.graphics.drawCircle(0, 0, radius - 1);
			knob.buttonMode = true;
			return knob;
		}
		
		public function get hue():Number 
		{
			return _hue;
		}
		
		public function setHue(value:Number, dispatchChange:Boolean):void 
		{
			_hue = value;
		}
		
		private function knob_mouseDownHandler(e:MouseEvent):void 
		{
			isMouseDown = true;
			stageLocal = dragKnob.stage;
			stageLocal.addEventListener(MouseEvent.MOUSE_MOVE, knob_mouseMoveHandler);
			stageLocal.addEventListener(MouseEvent.MOUSE_UP, knob_mouseUpHandler);
			lastMouseAngle = getMouseAngle();
			lastKnobAngle = getKnobAngle();
		}
		
		private function knob_mouseUpHandler(e:MouseEvent):void 
		{
			isMouseDown = false;
			stageLocal.removeEventListener(MouseEvent.MOUSE_MOVE, knob_mouseMoveHandler);
			stageLocal.removeEventListener(MouseEvent.MOUSE_UP, knob_mouseUpHandler);
		}
		
		private function knob_mouseMoveHandler(e:MouseEvent):void 
		{
			var angle:Number = lastKnobAngle + getMouseAngle() - lastMouseAngle;
			setKnobAngle(angle);
		}
		
		private function setKnobAngle(angle:Number):void 
		{
			var d:Number = radius - thickness * 0.5;
			dragKnob.x = Math.cos(angle) * d;
			dragKnob.y = Math.sin(angle) * d;
		}
		
		private function getKnobAngle():Number
		{
			return Math.atan2(dragKnob.y, dragKnob.x);
		}
		
		private function getMouseAngle():Number 
		{
			return Math.atan2(mouseY, mouseX);
		}
		
	}

}