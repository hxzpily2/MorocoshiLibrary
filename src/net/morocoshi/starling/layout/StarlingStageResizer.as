package net.morocoshi.starling.layout
{
	import flash.display.Stage;
	import flash.events.Event;
	import starling.core.Starling;
	
	/**
	 * Starlingの画面サイズをステージサイズに合わせる
	 * 
	 * @author tencho
	 */
	public class StarlingStageResizer
	{
		private var starling:Starling;
		private var fullScreenMode:Boolean;
		private var flashStage:Stage;
		
		public function StarlingStageResizer()
		{
		}
		
		/**
		 * Starlingのステージの自動リサイズを開始する
		 * @param	starling	Starlingオブジェクト
		 * @param	flashStage	FlashのStageオブジェクト
		 * @param	fullScreenMode	ステージサイズをフルスクリーン時のサイズにする
		 */
		public function startAutoResize(starling:Starling, flashStage:Stage, fullScreenMode:Boolean):void
		{
			this.starling = starling;
			this.fullScreenMode = fullScreenMode;
			this.flashStage = flashStage;
			flashStage.addEventListener(Event.RESIZE, stage_resizeHandler);
		}
		
		public function stopAutoResize():void
		{
			if (flashStage)
			{
				flashStage.removeEventListener(Event.RESIZE, stage_resizeHandler);
			}
		}
		
		protected function stage_resizeHandler(event:Event):void
		{
			var flashStage:Stage = event.currentTarget as Stage;
			var sw:Number = fullScreenMode? flashStage.fullScreenWidth : flashStage.stageWidth;
			var sh:Number = fullScreenMode? flashStage.fullScreenHeight : flashStage.stageHeight;
			starling.viewPort.width = starling.stage.stageWidth = sw;
			starling.viewPort.height = starling.stage.stageHeight = sh;
		}
	}
}