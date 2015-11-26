package net.morocoshi.moja3d.shaders.render 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class ZBiasShader extends MaterialShader 
	{
		private var _zbias:Number;
		private var zbiasConst:AGALConstant;
		
		public function ZBiasShader(zbias:Number) 
		{
			super();
			_zbias = zbias;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "ZBiasShader:";
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
			zbiasConst = vertexCode.addConstantsFromArray("@zbias", [_zbias, 0, 0, 0]);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			vertexCode.addCode(["$pos.w += @zbias.x"]);
		}
		
		override public function clone():MaterialShader 
		{
			return new ZBiasShader(_zbias);
		}
		
		public function get zbias():Number 
		{
			return _zbias;
		}
		
		public function set zbias(value:Number):void 
		{
			zbiasConst.x = _zbias = value;
		}
		
	}

}