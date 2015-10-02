package net.morocoshi.components.minimal.grid 
{
	import com.bit101.components.PushButton;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class ColumnData 
	{
		public var id:String;
		public var label:String;
		public var width:Number;
		public var classObject:Class;
		public var sortEnabled:Boolean = true;
		public var sortMode:Boolean = true;
		private var _enabled:Boolean = true;
		public var button:PushButton;
		internal var onClick:Function;
		
		public function ColumnData(id:String, label:String, width:Number, classObject:Class = null)
		{
			this.classObject = classObject;
			this.id = id;
			this.label = label;
			this.width = width;
			button = new PushButton(null, 0, 0, label, button_clickHandler);
		}
		
		private function button_clickHandler(e:MouseEvent):void 
		{
			onClick(this);
		}
		
		public function get enabled():Boolean 
		{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void 
		{
			_enabled = value;
		}
		
	}

}