package net.morocoshi.moja3d.shaders.render 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class RectKillShader extends MaterialShader 
	{
		private var _top:Number;
		private var _bottom:Number;
		private var _left:Number;
		private var _right:Number;
		private var rectConst:AGALConstant;
		
		public function RectKillShader() 
		{
			super();
			_top = Number.MAX_VALUE;
			_bottom = -Number.MAX_VALUE;
			_right = Number.MAX_VALUE;
			_left = -Number.MAX_VALUE;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "RectKillShader:";
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaMode = AlphaMode.NONE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
			
			rectConst = fragmentCode.addConstantsFromArray("@killRect", [_top, _right, _bottom, _left]);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			fragmentCode.addCode(
				"var $temp",
				"$temp.x = @killRect.y - #wpos.x",
				"kil $temp.x",
				"$temp.x = #wpos.x - @killRect.w",
				"kil $temp.x",
				"$temp.x = @killRect.x - #wpos.y",
				"kil $temp.x",
				"$temp.x = #wpos.y - @killRect.z",
				"kil $temp.x"
			);
		}
		
		override public function clone():MaterialShader 
		{
			var shader:RectKillShader = new RectKillShader();
			shader._top = _top;
			shader._bottom = _bottom;
			shader._left = _left;
			shader._right = _right;
			return shader;
		}
		
		public function get top():Number 
		{
			return _top;
		}
		
		public function set top(value:Number):void 
		{
			_top = value;
			rectConst.x = _top;
		}
		
		public function get bottom():Number 
		{
			return _bottom;
		}
		
		public function set bottom(value:Number):void 
		{
			_bottom = value;
			rectConst.z = _bottom;
		}
		
		public function get left():Number 
		{
			return _left;
		}
		
		public function set left(value:Number):void 
		{
			_left = value;
			rectConst.w = _left;
		}
		
		public function get right():Number 
		{
			return _right;
		}
		
		public function set right(value:Number):void 
		{
			_right = value;
			rectConst.y = _right;
		}
		
	}

}