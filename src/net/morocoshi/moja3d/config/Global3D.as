package net.morocoshi.moja3d.config 
{
	import flash.display.BlendMode;
	import net.morocoshi.moja3d.materials.preset.FillMaterial;
	import net.morocoshi.moja3d.primitives.Cube;
	import net.morocoshi.moja3d.shaders.render.DistanceFogShader;
	import net.morocoshi.moja3d.shaders.render.LightShader;
	import net.morocoshi.moja3d.shaders.shadow.ShadowShader;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Global3D 
	{
		static public var distanceFog:DistanceFogShader = new DistanceFogShader(0x808080, 0, 1000, 0, 1, BlendMode.NORMAL);
		static public var lightShader:LightShader = new LightShader();
		static public var shadowShader:ShadowShader = new ShadowShader();
		static public var debugCube:Cube = new Cube(10, 10, 10, 1, 1, 1, new FillMaterial(0xff4400, 1, true));
		static public var enableErrorChecking:Boolean = false;
		
		public function Global3D() 
		{
		}
		
	}

}