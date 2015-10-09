package net.morocoshi.moja3d.overlay.mouse 
{
	import flash.events.TouchEvent;
	import net.morocoshi.moja3d.overlay.objects.Object2D;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class MultiTouchManager 
	{
		private var allTouch:Object;
		private var _multitouchEnabled:Boolean;
		
		/**新しい指でタッチされた瞬間呼ばれる。引数にMultiTouchFingerオブジェクトが1つ*/
		public var onTouch:Function;
		
		public function MultiTouchManager(target:Object2D) 
		{
			_multitouchEnabled = true;
			allTouch = { };
			
			target.addEventListener(TouchEvent.TOUCH_BEGIN, touchHandler);
			target.screen.addEventListener(TouchEvent.TOUCH_MOVE, touchHandler);
			target.screen.addEventListener(TouchEvent.TOUCH_END, touchHandler);
		}
		
		public function get multitouchEnabled():Boolean
		{
			return _multitouchEnabled;
		}
		
		public function set multitouchEnabled(value:Boolean):void
		{
			_multitouchEnabled = value;
		}
		
		private function touchHandler(touch:TouchEvent):void 
		{
			var finger:MultiTouchFinger = allTouch[touch.touchPointID];
			if (finger == null)
			{
				if (touch.type == TouchEvent.TOUCH_BEGIN)
				{
					finger = allTouch[touch.touchPointID] = new MultiTouchFinger(touch);
					if (onTouch != null)
					{
						onTouch(finger);
					}
				}
				return;
			}
			
			if (finger.addTouchEvent(touch))
			{
				delete allTouch[touch.touchPointID];
			}
		}
		
	}

}