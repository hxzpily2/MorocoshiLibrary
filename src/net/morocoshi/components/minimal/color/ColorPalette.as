package net.morocoshi.components.minimal.color 
{
	import com.bit101.components.HUISlider;
	import com.bit101.components.Panel;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import net.morocoshi.common.graphics.Create;
	import net.morocoshi.common.graphics.Palette;
	
	/**
	 * カラーセレクタ用RGBスライダ
	 * 
	 * @author tencho
	 */
	public class ColorPalette extends Panel 
	{
		private var size:Rectangle;
		private var sliderR:HUISlider;
		private var sliderG:HUISlider;
		private var sliderB:HUISlider;
		private var sliders:Vector.<HUISlider>;
		private var colors:Array;
		private var selector:ColorSelector;
		private var isDisplaying:Boolean;
		private var colorBox:Sprite;
		private var boxWidth:Number;
		private var ring:HueRingSelector;
		private var svBox:SVBoxSelector;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function ColorPalette() 
		{
			super();
			isDisplaying = false;
			boxWidth = 15;
			size = new Rectangle(0, 0, 0x80 + 55 + boxWidth, 50);
			setSize(size.width, size.height);
			
			colors = [0, 0, 0];
			sliders = new Vector.<HUISlider>;
			colorBox = Create.box(0, 0, boxWidth, size.height - 4, 0x0);
			colorBox.x = 2;
			colorBox.y = 2;
			ring = new HueRingSelector(60, 15);
			ring.x = 100;
			ring.y = 110;
			
			
			var RGB:Array = ["R", "G", "B"];
			for (var i:int = 0; i < 3; i++) 
			{
				var ty:Number = i * 15;
				var label:TextField = new TextField();
				label.x = boxWidth + 3;
				label.y = ty;
				label.defaultTextFormat = new TextFormat("Arial", 12, 0x0);
				label.selectable = false;
				label.text = RGB[i];
				label.autoSize = TextFieldAutoSize.LEFT;
				addChild(label);
				
				var slider:HUISlider = new HUISlider(this, 0, 0, "", changeSlider);
				slider.x = boxWidth + 7;
				slider.y = ty;
				slider.tag = i;
				slider.minimum = 0x00;
				slider.maximum = 0xFF;
				slider.tick = 1;
				slider.labelPrecision = 0;
				slider.width = 0x80 + 70;
				slider.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
				sliders.push(slider);
			}
			svBox = new SVBoxSelector(50, 50);
			svBox.x = ring.x - svBox.width * 0.5;
			svBox.y = ring.y - svBox.height * 0.5;
			
			addChild(colorBox);
			//addChild(ring);
			//addChild(svBox);
		}
		
		/**
		 * カラーセレクタとリンクさせる
		 * @param	selector
		 */
		public function linkFrom(selector:ColorSelector):void
		{
			this.selector = selector;
			colors[0] = sliders[0].value = selector.value >>> 16 & 0xFF;
			colors[1] = sliders[1].value = selector.value >>> 8 & 0xFF;
			colors[2] = sliders[2].value = selector.value >>> 0 & 0xFF;
			applyColor();
		}
		
		/**
		 * Stageと位置を渡して表示する
		 * @param	stage
		 * @param	pos
		 */
		public function showTo(stage:Stage, pos:Point):void 
		{
			var w:int = stage.stageWidth - size.width;
			var h:int = stage.stageHeight - size.height;
			isDisplaying = true;
			stage.addChild(this);
			var tx:Number = pos.x;
			var ty:Number = pos.y;
			if (ty > h) ty = h;
			if (ty < 0) ty = 0;
			if (tx > w) tx = w;
			if (tx < 0) tx = 0;
			x = tx;
			y = ty;
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		
		//--------------------------------------------------------------------------
		//
		//  内部処理
		//
		//--------------------------------------------------------------------------
		
		private function applyColor():void 
		{
			var r:uint = colors[0];
			var g:uint = colors[1];
			var b:uint = colors[2];
			selector.setColor(r << 16 | g << 8 | b);
			colorBox.transform.colorTransform = Palette.getFillColor(selector.value);
		}
		
		private function mouseWheelHandler(e:MouseEvent):void 
		{
			if (!isDisplaying) return;
			var slider:HUISlider = e.currentTarget as HUISlider;
			var tag:int = slider.tag;
			slider.value += (e.delta < 0)? -1 : 1;
			colors[tag] = slider.value;
			applyColor();
		}
		
		private function changeSlider(e:Event):void 
		{
			var slider:HUISlider = e.currentTarget as HUISlider;
			var tag:int = slider.tag;
			colors[tag] = slider.value;
			applyColor();
		}
		
		private function mouseDownHandler(e:MouseEvent):void 
		{
			if (hitTestPoint(parent.mouseX, parent.mouseY, false)) return;
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			if (parent) parent.removeChild(this);
			isDisplaying = false;
		}
		
	}

}