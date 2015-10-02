package net.morocoshi.moja3d.shaders.render 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	/**
	 * ...
	 * @author tencho
	 */
	public class KillShader extends MaterialShader 
	{
		private var _height:Number;
		private var _reverse:Boolean;
		private var constant:AGALConstant;
		
		public function KillShader() 
		{
			super();
			_height = 0;
			_reverse = false;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "KillShader:";
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
			
			//[height, reverse, -2]
			constant = fragmentCode.addConstantsFromArray("@kill", [0, 0, -2, 0]);
			height = _height;
			reverse = _reverse;
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			fragmentConstants.number = true;
			
			fragmentCode.addCode(
				"var $temp",
				//@kil.yが1か0かで$temp.zwが_heightか0になる
				"$temp.z = @kill.y",
				"$temp.x = sne($temp.z, @1)",
				"$temp.y = seq($temp.z, @1)",
				
				"$temp.z = $temp.x * @kill.x",
				"$temp.w = $temp.y * @kill.x",
				
				"$temp.x = #wpos.z - $temp.z",
				
				//temp.y(0,1) * -2 + 1 = 1,-1
				"$temp.y *= @kill.z",
				"$temp.y += @1",
				"$temp.x *= $temp.y",
				
				"$temp.x += $temp.w",
				
				"kil $temp.x"
			);
		}
		
		public function get height():Number 
		{
			return _height;
		}
		
		public function set height(value:Number):void 
		{
			_height = value;
			constant.x = _height;
		}
		
		public function get reverse():Boolean 
		{
			return _reverse;
		}
		
		public function set reverse(value:Boolean):void 
		{
			_reverse = value;
			constant.y = int(_reverse);
		}
		
		override public function clone():MaterialShader 
		{
			var shader:KillShader = new KillShader();
			shader.height = _height;
			shader.reverse = _reverse;
			return shader;
		}
		
	}

}