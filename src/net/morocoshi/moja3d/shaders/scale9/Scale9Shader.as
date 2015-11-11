package net.morocoshi.moja3d.shaders.scale9 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.renderer.RenderLayer;
	import net.morocoshi.moja3d.resources.Geometry;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ...
	 * 
	 * @author ...
	 */
	public class Scale9Shader extends MaterialShader 
	{
		private var constant:AGALConstant;
		private var geometry:Geometry;
		
		public function Scale9Shader(geometry:Geometry) 
		{
			super();
			this.geometry = geometry;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "Scale9Shader:";
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
			constant = vertexCode.addConstantsFromArray("@scale9", [-4, 4, -4, 4]);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			var va:String = "va" + geometry.getAttributeIndex(VertexAttribute.SCALE9);
			vertexConstants.number = true;
			
			vertexCode.addCode(
				"var $split",
				"$split.x = " + va + ".x +" + va + ".y",
				"$split.y = " + va + ".z +" + va + ".w",
				"$split.xy = @1_1 - $split.xy",
				"$pos.xy *= $split.xy",
				"$split.x = @scale9.x * " + va + ".x",
				"$split.y = @scale9.y * " + va + ".y",
				"$split.z = @scale9.z * " + va + ".z",
				"$split.w = @scale9.w * " + va + ".w",
				"$pos.x += $split.x",
				"$pos.x += $split.y",
				"$pos.y += $split.z",
				"$pos.y += $split.w"
			);
		}
		
		override public function clone():MaterialShader 
		{
			var shader:Scale9Shader = new Scale9Shader(geometry);
			return shader;
		}
		
	}

}