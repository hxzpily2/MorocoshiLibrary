package net.morocoshi.components.balloon 
{
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import net.morocoshi.common.graphics.Create;
	
	/**
	 * マウスオーバーヘルプ
	 * 
	 * @author tencho
	 */
	public class MouseOverLabel 
	{
		static private var _instance:MouseOverLabel = new MouseOverLabel();
		public var container:Sprite;
		public var offset:Point;
		private var label:Sprite;
		private var frame:Sprite;
		private var base:Sprite;
		private var textField:TextField;
		private var textLink:Dictionary;
		private var startTime:int;
		private var stage:Stage;
		private var activeTarget:InteractiveObject;
		private var border:Number;
		private var margin:Number;
		private var count:int;
		
		public function MouseOverLabel() 
		{
			//AIRは複数Stageが存在できるから本当はシングルトンにしない方がいいかも・・
			if (_instance) throw new Error("MouseOverLabelのインスタンスは1つしか作れません。");
			
			border = 1;
			margin = 3;
			offset = new Point(0, 22);
			container = new Sprite();
			container.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			textLink = new Dictionary();
			
			label = new Sprite();
			label.filters = [new DropShadowFilter(2, 45, 0, 0.5, 3, 3, 1, 1)];
			container.mouseChildren = false;
			container.mouseEnabled = false;
			frame = label.addChild(Create.box(0, 0, 10, 10, 0x444444)) as Sprite;
			base = label.addChild(Create.box(0, 0, 8, 8, 0xf0f0f0)) as Sprite;
			base.x = base.y = border;
			
			textField = label.addChild(new TextField()) as TextField;
			textField.x = textField.y = border;
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.embedFonts = false;
			textField.selectable = false;
			textField.defaultTextFormat = new TextFormat("Meiryo", 12, 0x0);
			
			container.addChild(label);
			label.visible = false;
			setSize(120, 20);
		}
		
		private function addedToStageHandler(e:Event):void 
		{
			stage = container.stage;
		}
		
		static public function get instance():MouseOverLabel 
		{
			return _instance;
		}
		
		public function get defaultTextFormat():TextFormat 
		{
			return textField.defaultTextFormat;
		}
		
		public function set defaultTextFormat(value:TextFormat):void 
		{
			textField.defaultTextFormat = value;
		}
		
		public function setSize(w:Number, h:Number):void
		{
			frame.width = w;
			frame.height = h;
			base.x = base.y = border;
			base.width = w - border * 2;
			base.height = h - border * 2;
		}
		
		public function setLabel(target:InteractiveObject, text:String, autoRemoveEvent:Boolean = true):void
		{
			target.addEventListener(MouseEvent.ROLL_OVER, button_rollOverHandler);
			target.addEventListener(MouseEvent.ROLL_OUT, button_rollOutHandler);
			if (autoRemoveEvent)
			{
				target.addEventListener(Event.REMOVED_FROM_STAGE, target_removeFromStageHandler);
			}
			textLink[target] = text;
		}
		
		private function target_removeFromStageHandler(e:Event):void 
		{
			var target:InteractiveObject = e.currentTarget as InteractiveObject;
			removeLabel(target);
		}
		
		public function removeLabel(target:InteractiveObject):void
		{
			target.removeEventListener(Event.REMOVED_FROM_STAGE, target_removeFromStageHandler);
			target.removeEventListener(MouseEvent.ROLL_OVER, button_rollOverHandler);
			target.removeEventListener(MouseEvent.ROLL_OUT, button_rollOutHandler);
			delete textLink[target];
		}
		
		private function button_rollOverHandler(e:MouseEvent):void 
		{
			activeTarget = e.currentTarget as InteractiveObject;
			container.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			startTime = getTimer();
		}
		
		private function button_rollOutHandler(e:MouseEvent):void
		{
			container.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			hide();
		}
		
		private function enterFrameHandler(e:Event):void 
		{
			if (count++ % 10 != 0) return;
			if (getTimer() - startTime > 750)
			{
				var px:Number = stage.mouseX + offset.x;
				var py:Number = stage.mouseY + offset.y;
				if (px > stage.stageWidth - frame.width) px = stage.stageWidth - frame.width;
				if (py > stage.stageHeight - frame.height) py = stage.mouseY - frame.height - 8;
				show(textLink[activeTarget], px, py);
			}
		}
		
		public function hide():void
		{
			label.visible = false;
		}
		
		public function show(text:String, x:Number, y:Number):void 
		{
			textField.text = text;
			textField.x = margin + border - 2;
			textField.y = margin + border - 2;
			var tw:Number = textField.textWidth + (margin + border) * 2;
			var th:Number = textField.textHeight + (margin + border) * 2;
			setSize(tw, th);
			label.x = x;
			label.y = y;
			label.visible = true;
		}

	}

}