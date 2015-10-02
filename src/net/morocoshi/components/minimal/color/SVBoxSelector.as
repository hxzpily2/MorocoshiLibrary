package net.morocoshi.components.minimal.color 
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import net.morocoshi.graphics.Create;
	import net.morocoshi.graphics.Palette;
	import net.morocoshi.mouse.MouseDrag2D;
	/**
	 * ...
	 * @author tencho
	 */
	public class SVBoxSelector extends Sprite
	{
		public var size:Rectangle;
		
		private var sLayer:Sprite;
		private var vLayer:Sprite;
		private var color:Sprite;
		private var knob:Sprite;
		private var stageLocal:Stage;
		private var drag:MouseDrag2D;
		
		public function SVBoxSelector(width:Number, height:Number) 
		{
			super();
			size = new Rectangle(0, 0, width, height);
			color = Create.box(0, 0, width, height, 0x000000);
			vLayer = Create.gradientBox(0, 0, width, height, true, 90, [0x000000, 0x000000], [1, 0]);
			sLayer = Create.gradientBox(0, 0, width, height, true, 0, [0xffffff, 0xffffff], [1, 0]);
			
			knob = createKnob(5);
			
			drag = new MouseDrag2D();
			drag.init(knob, this);
			drag.wheelEnabled = false;
			drag.setPoint(knob.x, knob.y);
			drag.addEventListener(MouseEvent.MOUSE_MOVE, knob_mouseMoveHandler);
			
			addChild(color);
			addChild(sLayer);
			addChild(vLayer);
			addChild(knob);
			setHue(90 / 180 * Math.PI);
		}
		
		/**
		 * radian角で色相を設定
		 * @param	h
		 */
		public function setHue(h:Number):void
		{
			var rgb:uint = Palette.HLStoRGB(h / Math.PI * 180, 0.5, 1);
			color.transform.colorTransform = Palette.getFillColor(rgb, 1, 1);
		}
		
		public function setSV(s:Number, v:Number):void
		{
			knob.x = s * size.width;
			knob.y = v * size.height;
		}
		
		
		private function knob_mouseMoveHandler(e:MouseEvent):void 
		{
			knob.x = drag.position.x;
			knob.y = drag.position.y;
		}
		
		/*
		private function knob_mouseDownHandler(e:MouseEvent):void 
		{
			stageLocal = knob.stage;
			stageLocal.addEventListener(MouseEvent.MOUSE_UP, knob_mouseUpHandler);
			stageLocal.addEventListener(MouseEvent.MOUSE_MOVE, knob_mouseMoveHandler);
		}
		
		private function knob_mouseUpHandler(e:MouseEvent):void 
		{
			
		}
		*/
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
		
	}

}