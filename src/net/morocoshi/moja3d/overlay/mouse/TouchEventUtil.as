package net.morocoshi.moja3d.overlay.mouse 
{
	import flash.events.TouchEvent;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class TouchEventUtil 
	{
		
		static public function cloneEvent(e:TouchEvent, type:String = null, localX:Number = NaN, localY:Number = NaN):TouchEvent 
		{
			var tx:Number = isNaN(localX)? e.localX : localX;
			var ty:Number = isNaN(localY)? e.localY : localY;
			if (type == null) type = e.type;
			//return new TouchEvent(type, e.bubbles, e.cancelable, e.touchPointID, e.isPrimaryTouchPoint, tx, ty, e.sizeX, e.sizeY, e.pressure, e.relatedObject, e.ctrlKey, e.altKey, e.shiftKey, e.commandKey, e.controlKey, e.timestamp, e.touchIntent, null, e.isTouchPointCanceled);
			var cloned:TouchEvent = new TouchEvent(type, e.bubbles, e.cancelable, e.touchPointID, e.isPrimaryTouchPoint, tx, ty, e.sizeX, e.sizeY, e.pressure, e.relatedObject, e.ctrlKey, e.altKey, e.shiftKey);
			//, e.commandKey, e.controlKey, e.timestamp, e.touchIntent, null, e.isTouchPointCanceled);
			return cloned;
		}
		
	}

}