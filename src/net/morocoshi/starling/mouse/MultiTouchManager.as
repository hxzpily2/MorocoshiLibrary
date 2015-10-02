package net.morocoshi.starling.mouse 
{
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class MultiTouchManager 
	{
		private var target:DisplayObject;
		private var touchList:Vector.<Touch>;
		private var allTouch:Object;
		private var object:DisplayObject;

		public function get multitouchEnabled():Boolean
		{
			return _multitouchEnabled;
		}
		
		public function set multitouchEnabled(value:Boolean):void
		{
			_multitouchEnabled = value;
		}

		/**新しい指でタッチされた瞬間呼ばれる。引数にMultiTouchFingerオブジェクトが1つ*/
		public var onTouch:Function;
		private var _multitouchEnabled:Boolean;
		
		/**
		 * 
		 * @param	object	タッチイベントを登録する対象
		 * @param	target	Local座標を取得する際の基準オブジェクト
		 */
		public function MultiTouchManager(object:DisplayObject, target:DisplayObject = null) 
		{
			_multitouchEnabled = !true;
			touchList = new Vector.<Touch>;
			allTouch = { };
			this.object = object;
			this.target = target? target : object;
			object.addEventListener(TouchEvent.TOUCH, touchHandler);
		}
		
		private function touchHandler(e:TouchEvent):void 
		{
			//マルチタッチ可能な時は複数イベントを取得
			if(Starling.multitouchEnabled)
			{
				e.getTouches(object, null, touchList);
				for each (var touch:Touch in touchList) 
				{
					inputTouch(touch);
				}
			}
			else
			{
				//マルチタッチ不可な場合はこっち
				var singleTouch:Touch = e.getTouch(object);
				if (singleTouch)
				{
					inputTouch(singleTouch);
				}
			}
		}
		
		private function inputTouch(touch:Touch):void
		{
			if(touch.phase == TouchPhase.HOVER) return;
			
			var finger:MultiTouchFinger = allTouch[touch.id];
			if (finger == null)
			{
				if (touch.phase == TouchPhase.BEGAN && onTouch != null)
				{
					finger = allTouch[touch.id] = new MultiTouchFinger(touch, target);
					onTouch(finger);
				}
				return;
			}
			
			if (finger.setTouch(touch))
			{
				delete allTouch[touch.id];
			}
		}
		
	}

}