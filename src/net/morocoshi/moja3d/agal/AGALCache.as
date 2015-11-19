package net.morocoshi.moja3d.agal 
{
	import net.morocoshi.common.data.DataUtil;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.objects.Mesh;
	import net.morocoshi.moja3d.shaders.core.ViewTransformShader;
	import net.morocoshi.moja3d.shaders.overlay.SpriteBasicShader;
	import net.morocoshi.moja3d.shaders.overlay.SpriteEndShader;
	import net.morocoshi.moja3d.shaders.ShaderList;
	
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
			DataUtil.deleteObject(program);
			DataUtil.deleteObject(vertexConstant);
			DataUtil.deleteObject(fragmentConstant);
			program = { };
			var key:String;
			var item:*;
			for (key in shader)
			{
				item = shader[key];
				if (item is ShaderList)
				{
					ShaderList(item).finaly();
				}
				else
				{
					if (item.opaque)
					{
						item.opaque.finaly();
					}
					if (item.alpha)
					{
						item.alpha.finaly();
					}
					DataUtil.deleteObject(item);
				}
			}
			item = null;
			key = null;
			DataUtil.deleteObject(shader);
			shader = { };
			vertexConstant = { };
			fragmentConstant = { };
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