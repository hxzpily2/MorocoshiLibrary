package net.morocoshi.moja3d.config 
{
	import flash.display.BlendMode;
	import net.morocoshi.moja3d.materials.preset.FillMaterial;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.primitives.Cube;
	import net.morocoshi.moja3d.shaders.render.DistanceColorFogShader;
	import net.morocoshi.moja3d.shaders.render.LightShader;
	import net.morocoshi.moja3d.shaders.shadow.ShadowShader;
	
	/**
	 * よく使うシェーダー等をまとめたもの
	 * 
	 * @author tencho
	 */
	public class Global3D 
	{
		static public var distanceFog:DistanceColorFogShader = new DistanceColorFogShader(0x808080, 0, 1000, 0, 1, BlendMode.NORMAL);
		static public var lightShader:LightShader = new LightShader();
		static public var shadowShader:ShadowShader = new ShadowShader();
		static moja3d var boundingCube:Cube = new Cube(1, 1, 1, 1, 1, 1, new FillMaterial(0xff0000, 0.5, true));
		static public var debugCube:Cube = new Cube(10, 10, 10, 1, 1, 1, new FillMaterial(0xff4400, 1, true));
		static public var enableErrorChecking:Boolean = false;
		
		public function Global3D() 
		{
		}
		
	}

}