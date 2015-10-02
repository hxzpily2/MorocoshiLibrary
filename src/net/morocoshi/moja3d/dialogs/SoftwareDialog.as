package net.morocoshi.moja3d.dialogs 
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.Security;
	import flash.system.SecurityPanel;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ユーザーの設定でソフトウェアレンダリングになっている事を知らせるウィンドウ。作り途中。
	 * 
	 * @author tencho
	 */
	public class SoftwareDialog extends Sprite 
	{
		private var frame:Sprite;
		private var label:TextField;
		private var localStage:Stage;
		
		public function SoftwareDialog() 
		{
			super();
			
			frame = new Sprite();
			
			var g:Graphics = frame.graphics;
			g.beginFill(0x0, 1);
			g.drawRoundRect(0, 0, 300, 100, 5, 5);
			g.endFill();
			
			frame.mouseEnabled = true;
			frame.mouseChildren = false;
			frame.buttonMode = true;
			frame.addEventListener(MouseEvent.CLICK, show_clickHandler);
			
			label = new TextField();
			label.defaultTextFormat = new TextFormat(null, 12, 0xffffff);
			label.autoSize = "left";
			label.wordWrap = true;
			label.text = "ソフトウェアレンダリングになっているため動作が遅い可能性があります。設定パネルを開いてハードウェアレンダリングを手動で有効にしますか？";
			label.width = frame.width - 20;
			label.x = 10;
			label.y = 10;
			addChild(frame);
			addChild(label);
		}
		
		public function autoAlignCenter():void 
		{
			if (stage)
			{
				addedToStageHandler(null);
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			}
		}
		
		private function addedToStageHandler(e:Event):void 
		{
			if (e)
			{
				removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			}
			localStage = stage;
			localStage.addEventListener(Event.RESIZE, stage_resizeHandler);
			stage_resizeHandler(null);
		}
		
		private function stage_resizeHandler(e:Event):void 
		{
			x = (localStage.stageWidth - width) / 2;
			y = (localStage.stageHeight - height) / 2;
			visible = true;
		}
		
		private function show_clickHandler(e:MouseEvent):void 
		{
			visible = false;
			if (parent)
			{
				parent.removeChild(this);
			}
			Security.showSettings(SecurityPanel.DISPLAY);
		}
		
	}

}