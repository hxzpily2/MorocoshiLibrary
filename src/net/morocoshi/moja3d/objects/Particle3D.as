package net.morocoshi.moja3d.objects 
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DCompareMode;
	import net.morocoshi.moja3d.materials.Material;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.particle.cells.ParticleData;
	import net.morocoshi.moja3d.resources.ParticleGeometry;
	import net.morocoshi.moja3d.shaders.particle.ParticleShader;
	import net.morocoshi.moja3d.shaders.render.VertexColorShader;
	import net.morocoshi.moja3d.shaders.ShaderList;
	
	use namespace moja3d;
	
	/**
	 * パーティクルを表示する基本クラス
	 * 
	 * @author tencho
	 */
	public class Particle3D extends Mesh
	{
		private var surface:Surface;
		private var particleShader:ParticleShader;
		public var particles:Vector.<ParticleData>;
		
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
		
		public function update(context3D:Context3D):void
		{
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