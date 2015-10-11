package net.morocoshi.moja3d.agal 
{
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.objects.Mesh;
	import net.morocoshi.moja3d.shaders.core.ViewTransformShader;
	import net.morocoshi.moja3d.shaders.overlay.SpriteBasicShader;
	import net.morocoshi.moja3d.shaders.overlay.SpriteEndShader;
	
	use namespace moja3d;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class AGALCache 
	{
		
		static public var program:Object = { };
		static public var spriteStartShaderList:SpriteBasicShader = new SpriteBasicShader();
		static public var spriteEndShaderList:SpriteEndShader = new SpriteEndShader();
		static public var viewShaderList:ViewTransformShader = new ViewTransformShader();
		
		static public var shader:Object = { };
		
		static public var vertexConstant:Object = { };
		static public var fragmentConstant:Object = { };
		
		public function AGALCache() 
		{
		}
		
		static public function clear():void
		{
			Mesh.globalSeed = 0;
			program = { };
			shader = { };
		}
		
		static public function dispose():void
		{
			program = null;
			shader = null;
			vertexConstant = null;
			fragmentConstant = null;
		}
		
	}

}