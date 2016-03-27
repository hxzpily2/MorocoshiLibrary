package net.morocoshi.moja3d.shaders.render 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.renderer.RenderLayer;
	import net.morocoshi.moja3d.shaders.AlphaTransform;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * デカール処理
	 * 
	 * @author tencho
	 */
	public class DecalShader extends MaterialShader 
	{
		private var _offset:Number;
		private var offsetConst:AGALConstant;
		
		public function DecalShader(offset:Number = 0) 
		{
			super();
			
			_offset = offset;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "DecalShader:";
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaTransform = AlphaTransform.UNCHANGE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
			
			offsetConst = vertexCode.addConstantsFromArray("@decal", [_offset, 0, 0, 0]);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			vertexCode.addCode(["$pos.z += @decal.x"]);
		}
		
		override public function clone():MaterialShader 
		{
			return new DecalShader(_offset);
		}
		
		public function get offset():Number 
		{
			return _offset;
		}
		
		public function set offset(value:Number):void 
		{
			_offset = value;
			offsetConst.x = _offset;
		}
		
	}

}