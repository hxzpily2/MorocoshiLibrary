package net.morocoshi.components.minimal.layout 
{
	import com.bit101.components.Component;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	/**
	 * ...
	 * @author tencho
	 */
	public class PaddingBox extends Component
	{
		private var _top:Number = 0;
		private var _bottom:Number = 0;
		private var _left:Number = 0;
		private var _right:Number = 0;
		
		public function PaddingBox(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, content:Component = null, top:Number = 0, right:Number = 0, bottom:Number = 0, left:Number = 0)
		{
			super(parent, xpos, ypos);
			_top = top;
			_bottom = bottom;
			_left = left;
			_right = right;
			if (content) addChild(content);
		}
		
		public function setPadding(value:Number):void
		{
			_top = _bottom = _left = _right = value;
		}
		
		public function updateLayout():void
		{
			var target:Component = content;
			if (!target) return;
			var w:Number = _width - _left - _right;
			var h:Number = _height - _top - _bottom;
			if (w < 0) w = 0;
			if (h < 0) h = 0;
			target.x = _left;
			target.y = _top;
			target.setSize(w, h);
		}
		
		public function get top():Number 
		{
			return _top;
		}
		
		public function set top(value:Number):void 
		{
			_top = value;
			updateLayout();
		}
		
		public function get bottom():Number 
		{
			return _bottom;
		}
		
		public function set bottom(value:Number):void 
		{
			_bottom = value;
			updateLayout();
		}
		
		public function get left():Number 
		{
			return _left;
		}
		
		public function set left(value:Number):void 
		{
			_left = value;
			updateLayout();
		}
		
		public function get right():Number 
		{
			return _right;
		}
		
		public function set right(value:Number):void 
		{
			_right = value;
			updateLayout();
		}
		
		public function set content(value:Component):void
		{
			if (content)
			{
				content.parent.removeChild(content);
			}
			addChildAt(value, 0);
			updateLayout();
		}
		
		public function get content():Component 
		{
			return !numChildren? null : getChildAt(0) as Component;
		}
		
		override public function setSize(w:Number, h:Number):void 
		{
			super.setSize(w, h);
			updateLayout();
		}
		
	}

}