package net.morocoshi.moja3d.events 
{
	import flash.events.Event;
	import net.morocoshi.moja3d.collision.CollisionResult;
	
	/**
	 * マウスイベント
	 * 
	 * @author tencho
	 */
	public class MouseEvent3D extends Event 
	{
		static public const CLICK:String = "click";
		static public const MOUSE_DOWN:String = "mouseDown";
		static public const MOUSE_UP:String = "mouseUp";
		/**
		 * メッシュオブジェクト表面におけるマウス位置のローカル座標が変化した際に呼び出される。
		 * マウスが動いていなくても、マウス位置にあるメッシュが動けば呼び出される。
		 * Scene3Dにイベントを登録した場合、マウス位置にメッシュがなければマウスを動かしていても呼び出されないが、
		 * メッシュ上から何もない空間にマウスを移動した際に一度だけ衝突情報なしのイベントが発行される。
		 */
		static public const MOUSE_MOVE:String = "mouseMove";
		static public const MOUSE_OVER:String = "mouseOver";
		static public const MOUSE_OUT:String = "mouseOut";
		
		public var collision:CollisionResult;
		
		public function MouseEvent3D(type:String, collision:CollisionResult, bubbles:Boolean = false, cancelable:Boolean = false)
		{ 
			super(type, bubbles, cancelable);
			this.collision = collision;
		}
		
		public override function clone():Event 
		{ 
			return new MouseEvent3D(type, collision, bubbles, cancelable);
		}
		
		public override function toString():String 
		{ 
			return formatToString("MouseEvent3D", "type", "collision", "bubbles", "cancelable", "eventPhase");
		}
		
	}
	
}