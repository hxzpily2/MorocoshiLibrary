package net.morocoshi.moja3d.shaders.line 
{
	import net.morocoshi.moja3d.renderer.RenderPhase;
	import net.morocoshi.moja3d.resources.Geometry;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class LineShader extends MaterialShader 
	{
		private var _geometry:Geometry;
		
		public function LineShader(geometry:Geometry) 
		{
			super();
			_geometry = geometry;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "LineShader:";
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			//alphaTransform = AlphaTransform.SET_MIXTURE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			var va:String = "va" + geometry.getAttributeIndex(VertexAttribute.LINE_VECTOR);
			
			vertexConstants.cameraPosition = true;
			vertexConstants.modelMatrix = true;
			vertexConstants.projMatrix = true;
			vertexConstants.viewMatrix = true;
			vertexConstants.number = true;
			
			vertexCode.addCode([
				"global $thick",
				"$thick.xyz = " + va + ".xyz",
				"$thick.xyz = m33($thick.xyz, @modelMatrix)",//モデル行列で変換
				"var $eye",
				"$eye.xyz = $pos.xyz - @cameraPosition.xyz",
				
				"$thick.xyz = crs($thick.xyz, $eye.xyz)",
				"$thick.xyz = nrm($thick.xyz)",
				
				"$thick.xyz = m33($thick.xyz, @viewMatrix)",//行列で変換
				"$thick.xyz = m33($thick.xyz, @projMatrix)"//行列で変換
				
				//"$thick.xyz *= " + va2 + ".x",
				//"$pos.xyz += $thick.xyz"
			]);
			
			fragmentCode.addCode([
				"$output = #vcolor"
			]);
		}
		
		override public function getExtraShader(phase:String):MaterialShader 
		{
			if (phase == RenderPhase.SHADOW)
			{
				return new LineShader(geometry);
			}
			if (phase == RenderPhase.REFLECT)
			{
				return new LineShader(geometry);
			}
			if (phase == RenderPhase.MASK)
			{
				return new LineShader(geometry);
			}
			return null;
		}
		
		override public function clone():MaterialShader 
		{
			var shader:LineShader = new LineShader(geometry);
			return shader;
		}
		
		public function setAlphaTransform(value:uint):void
		{
			if (value == alphaTransform) return;
			alphaTransform = value;
			updateAlphaMode();
		}
		
		public function get geometry():Geometry 
		{
			return _geometry;
		}
		
		public function set geometry(value:Geometry):void 
		{
			_geometry = value;
			
			updateShaderCode();
		}
		
	}

}