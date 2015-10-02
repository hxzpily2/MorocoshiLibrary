package net.morocoshi.common.ui.mouse 
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class PlanarDragger 
	{
		private var sprite:Sprite;
		private var _matrix:Matrix3D;
		private var stage:Stage;
		private var lastX:Number;
		private var lastY:Number;
		private var mouseType:String;
		
		public var onMove:Function;
		
		static public const TYPE_MIDDLE:String = "typeMiddle";
		static public const TYPE_RIGHT:String = "typeRight";
		static public const TYPE_LEFT:String = "typeLeft";
		
		public function PlanarDragger() 
		{
			_matrix = new Matrix3D();
		}
		
		public function init(sprite:Sprite, type:String = TYPE_MIDDLE):void
		{
			this.mouseType = type;
			this.sprite = sprite;
			switch(type)
			{
				case TYPE_MIDDLE	: sprite.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, sprite_mouseDownHandler); break;
				case TYPE_RIGHT		: sprite.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, sprite_mouseDownHandler); break;
				case TYPE_LEFT		: sprite.addEventListener(MouseEvent.MOUSE_DOWN, sprite_mouseDownHandler); break;
			}
		}
		
		private function sprite_mouseDownHandler(e:MouseEvent):void 
		{
			lastX = e.stageX;
			lastY = e.stageY;
			stage = sprite.stage;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
			stage.addEventListener(Event.MOUSE_LEAVE, stage_mouseUpHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, stage_mouseUpHandler);
			switch(mouseType)
			{
				case TYPE_MIDDLE	: sprite.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, stage_mouseUpHandler); break;
				case TYPE_RIGHT		: sprite.addEventListener(MouseEvent.RIGHT_MOUSE_UP, stage_mouseUpHandler); break;
				case TYPE_LEFT		: sprite.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler); break;
			}
		}
		
		private function stage_mouseUpHandler(e:Event):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
			stage.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, stage_mouseUpHandler);
			stage.removeEventListener(MouseEvent.MIDDLE_MOUSE_UP, stage_mouseUpHandler);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
		}
		
		private function stage_mouseMoveHandler(e:MouseEvent):void 
		{
			var dx:Number = e.stageX - lastX;
			var dy:Number = e.stageY - lastY;
			lastX = e.stageX;
			lastY = e.stageY;
			var data:Vector.<Number> = _matrix.rawData;
			var xAxis:Vector3D = new Vector3D(data[0], data[1], data[2]);
			var yAxis:Vector3D = new Vector3D(data[4], data[5], -data[6]);
			xAxis.normalize();
			yAxis.normalize();
			xAxis.scaleBy(dx);
			yAxis.scaleBy(dy);
			onMove(xAxis.add(yAxis));
		}
		
		public function get matrix():Matrix3D 
		{
			return _matrix;
		}
		
		public function set matrix(value:Matrix3D):void 
		{
			_matrix = value;
		}
		
	}

}