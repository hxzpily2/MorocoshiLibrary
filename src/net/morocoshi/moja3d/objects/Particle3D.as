package net.morocoshi.moja3d.objects 
{
	import net.morocoshi.moja3d.materials.Material;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.particle.cells.ParticleData;
	import net.morocoshi.moja3d.resources.ParticleGeometry;
	import net.morocoshi.moja3d.shaders.particle.ParticleShader;
	import net.morocoshi.moja3d.shaders.render.VertexColorShader;
	import net.morocoshi.moja3d.shaders.ShaderList;
	import net.morocoshi.moja3d.view.ContextProxy;
	
	use namespace moja3d;
	
	/**
	 * パーティクルを表示する基本クラス
	 * 
	 * @author tencho
	 */
	public class Particle3D extends Mesh
	{
		protected var particles:Vector.<ParticleData>;
		private var context3D:ContextProxy;
		private var surface:Surface;
		private var particleShader:ParticleShader;
		
		public function Particle3D(material:Material) 
		{
			super();
			
			geometry = new ParticleGeometry();
			particles = new Vector.<ParticleData>;
			surface = new Surface(material, 0, 0);
			surfaces.push(surface);
			particleShader = new ParticleShader(_geometry);
			afterViewShaderList = new ShaderList();
			afterViewShaderList.addShader(new VertexColorShader());
			afterViewShaderList.addShader(particleShader);
		}
		
		public function setContetx3D(context3D:ContextProxy):void
		{
			this.context3D = context3D;
		}
		
		public function update():void
		{
			if (context3D == null) return;
			
			surface.numTriangles = particles.length * 2;
			ParticleGeometry(_geometry).update(particles, context3D);
		}
		
		public function get material():Material 
		{
			return surface.material;
		}
		
		public function set material(value:Material):void 
		{
			surface.material = value;
		}
		
	}

}