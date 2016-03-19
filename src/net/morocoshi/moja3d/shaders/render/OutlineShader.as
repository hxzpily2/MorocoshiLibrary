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
	public class OutlineShader extends MaterialShader 
	{
		private var _angle:Number;
		private var _color:uint;
		private var constant:AGALConstant;
		
		public function OutlineShader(angle:Number = 70, color:uint = 0x000000) 
		{
			super();
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
			
			this.angle = angle;
			this.color = color;
		}
		
		override public function getKey():String 
		{
			return "OutlineShader:";
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
			
			constant = fragmentCode.addConstantsFromArray("@toonOutline", [0, 0, 0, 0]);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			fragmentConstants.number = true;
			fragmentConstants.cameraPosition = true;
			fragmentCode.addCode([
				"var $temp",
				//視点からテクセルへのベクトル
				"$temp.xyz = #wpos.xyz - @cameraPosition.xyz",
				"$temp.xyz = nrm($temp.xyz)",
				"$temp.w = dp3($normal.xyz, $temp.xyz)",
				"$temp.w = sge($temp.w, @toonOutline.w)",
				"$temp.x = @1 - $temp.w",
				"$output.xyz *= $temp.xxx",
				"$temp.xyz = @toonOutline.xyz",
				"$temp.xyz *= $temp.www",
				"$output.xyz += $temp.xyz"
			]);
		}
		
		override public function clone():MaterialShader 
		{
			return new OutlineShader(_angle, _color);
		}
		
		public function get angle():Number 
		{
			return _angle;
		}
		
		public function set angle(value:Number):void 
		{
			_angle = value;
			constant.w = _angle / 90 - 1;
		}
		
		public function get color():uint 
		{
			return _color;
		}
		
		public function set color(value:uint):void 
		{
			_color = value;
			constant.setRGB(_color);
		}
		
	}

}