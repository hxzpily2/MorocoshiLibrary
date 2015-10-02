package net.morocoshi.moja3d.shaders.render 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class RectClipShader extends MaterialShader 
	{
		private var _left:Number;
		private var _top:Number;
		private var _right:Number;
		private var _bottom:Number;
		
		private var clipConst:AGALConstant;
		
		public function RectClipShader(left:Number, top:Number, right:Number, bottom:Number) 
		{
			super();
			
			_left = left;
			_top = top;
			_right = right;
			_bottom = bottom;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "RectClipShader:";
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
			
			clipConst = fragmentCode.addConstantsFromArray("@rectClip", [0, 0, 0, 0]);
			fragmentCode.addConstantsFromArray("@screen", [0.5, -0.5, 0, 0]);
			calculateConstants();
		}
		
		private function calculateConstants():void 
		{
			clipConst.x = (_left + _right) * 0.5;
			clipConst.y = (_top + _bottom) * 0.5;
			clipConst.z = (_right - _left) * 0.5;
			clipConst.w = (_bottom - _top) * 0.5;
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			fragmentConstants.viewSize = true;
			fragmentCode.addCode(
				"var $screen",
				//スクリーン位置（0-1）
				"$screen.xy = #spos.xy / #spos.w",
				"$screen.xy *= @screen.xy",
				"$screen.xy += @screen.x",
				
				"$screen.xy *= @viewSize.xy",
				"$screen.xy -= @rectClip.xy",
				"$screen.xy = abs($screen.xy)",
				"$screen.xy = @rectClip.zw - $screen.xy",
				"kil $screen.x",
				"kil $screen.y"
			);
		}
		
		override public function clone():MaterialShader 
		{
			var shader:RectClipShader = new RectClipShader(_left, _top, _right,_bottom);
			return shader;
		}
		
		public function get left():Number 
		{
			return _left;
		}
		
		public function set left(value:Number):void 
		{
			_left = value;
			calculateConstants();
		}
		
		public function get top():Number 
		{
			return _top;
		}
		
		public function set top(value:Number):void 
		{
			_top = value;
			calculateConstants();
		}
		
		public function get right():Number 
		{
			return _right;
		}
		
		public function set right(value:Number):void 
		{
			_right = value;
			calculateConstants();
		}
		
		public function get bottom():Number 
		{
			return _bottom;
		}
		
		public function set bottom(value:Number):void 
		{
			_bottom = value;
			calculateConstants();
		}
		
	}

}