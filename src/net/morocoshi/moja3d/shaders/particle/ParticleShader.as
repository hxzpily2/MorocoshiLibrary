package net.morocoshi.moja3d.shaders.particle 
{
	import net.morocoshi.moja3d.renderer.RenderPhase;
	import net.morocoshi.moja3d.resources.Geometry;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class ParticleShader extends MaterialShader 
	{
		private var geometry:Geometry;
		
		public function ParticleShader(geometry:Geometry) 
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
			return "ParticleShader:";
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaMode = AlphaMode.MIX;
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
			
			var va:String = "va" + geometry.getAttributeIndex(VertexAttribute.SIZE);
			vertexCode.addCode(
				"$pos.xy += " + va + ".xy"
			);
		}
		
		override public function getExtraShader(phase:String):MaterialShader 
		{
			if (phase == RenderPhase.DEPTH)
			{
				return new ParticleShader(geometry);
			}
			if (phase == RenderPhase.REFLECT)
			{
				return new ParticleShader(geometry);
			}
			if (phase == RenderPhase.MASK)
			{
				return new ParticleShader(geometry);
			}
			return null;
		}
		
		override public function clone():MaterialShader 
		{
			var shader:ParticleShader = new ParticleShader(geometry);
			return shader;
		}
		
	}

}