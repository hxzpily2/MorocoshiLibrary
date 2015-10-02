package net.morocoshi.moja3d.overlay.objects 
{
	import flash.events.TouchEvent;
	import net.morocoshi.common.data.Temp;
	import net.morocoshi.common.math.transform.TransformUtil;
	import net.morocoshi.moja3d.materials.Material;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.objects.Surface;
	import net.morocoshi.moja3d.overlay.mouse.OverlayTouchManager;
	import net.morocoshi.moja3d.overlay.mouse.TouchEventUtil;
	import net.morocoshi.moja3d.renderer.RenderCollector;
	import net.morocoshi.moja3d.shaders.overlay.SpriteBoxShader;
	
	use namespace moja3d;
	/**
	 * ...
	 * @author tencho
	 */
	public class Plane2D extends Sprite2D 
	{
		moja3d var _material:Material;
		private var _width:Number;
		private var _height:Number;
		private var _originX:Number;
		private var _originY:Number;
		private var boxShader:SpriteBoxShader;
		
		public function Plane2D(width:Number, height:Number, originX:Number = 0, originY:Number = 0) 
		{
			super();
			_originX = originX;
			_originY = originY;
			_width = width;
			_height = height;
			boxShader = new SpriteBoxShader(_originX, _originY, _width, _height);
			_material = new Material();
			_material.shaderList.addShader(boxShader);
			surfaces.push(new Surface(_material, 0, 2));
		}
		
		public function get blendMode():String 
		{
			return _material.blendMode;
		}
		
		public function set blendMode(value:String):void 
		{
			_material.blendMode = value;
		}
		
		public function get width():Number 
		{
			return _width;
		}
		
		public function set width(value:Number):void 
		{
			_width = value;
			boxShader.width = _width;
		}
		
		public function get height():Number 
		{
			return _height;
		}
		
		public function set height(value:Number):void 
		{
			_height = value;
			boxShader.height = _height;
		}
		
		public function get originX():Number 
		{
			return _originX;
		}
		
		public function set originX(value:Number):void 
		{
			_originX = value;
			boxShader.x = _originX;
		}
		
		public function get originY():Number 
		{
			return _originY;
		}
		
		public function set originY(value:Number):void 
		{
			_originY = value;
			boxShader.y = _originY;
		}
		
		public function get material():Material 
		{
			return _material;
		}
		
		public function set material(value:Material):void 
		{
			_material = value;
		}
		
		override moja3d function collectRenderElements(collector:RenderCollector, forceCalcMatrix:Boolean, forceCalcColor:Boolean, worldFlip:int):Boolean 
		{
			_geometry = collector.planeGeometry;
			return super.collectRenderElements(collector, forceCalcMatrix, forceCalcColor, worldFlip);
		}
		
		override moja3d function hitTestTouchEvent(touch:OverlayTouchManager, forceCalcMatrix:Boolean):Boolean
		{
			super.hitTestTouchEvent(touch, forceCalcMatrix);
			
			Temp.position.setTo(touch.touchPoint.x, touch.touchPoint.y, 0);
			Temp.matrix3D.copyFrom(_worldMatrix);
			Temp.matrix3D.invert();
			TransformUtil.transformVector(Temp.position, Temp.matrix3D);
			var tx:Number = Temp.position.x;
			var ty:Number = Temp.position.y;
			
			if (decomposeMatrixOrder) decomposeMatrix();
			if (-_originX * _width > tx) return false;
			if (-_originY * _height > ty) return false;
			if ((1 - _originX) * _width < tx) return false;
			if ((1 - _originY) * _height < ty) return false;
			
			//var te:TouchEvent = ;
			//touch.dispatchTouchEvent(this, touch.touchEvent, tx, ty);
			//new TouchEvent(te.type, te.bubbles, te.cancelable, te.touchPointID, te.isPrimaryTouchPoint, tx, ty, te.sizeX, te.sizeY, te.pressure, te.relatedObject, te.ctrlKey, te.altKey, te.shiftKey, te.commandKey, te.controlKey, te.timestamp, te.touchIntent);
			var event:TouchEvent = TouchEventUtil.cloneEvent(touch.touchEvent, null, tx, ty);
			dispatchEvent(event);
			
			var current:Object2D = _parent;
			while(current) 
			{
				Temp.position.setTo(touch.touchPoint.x, touch.touchPoint.y, 0);
				Temp.matrix3D.copyFrom(current._worldMatrix);
				Temp.matrix3D.invert();
				TransformUtil.transformVector(Temp.position, Temp.matrix3D);
				touch.dispatchTouchEvent(current, touch.touchEvent, Temp.position.x, Temp.position.y);
				current = current._parent;
			}
			return true;
		}
		
	}

}