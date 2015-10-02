package net.morocoshi.common.loaders.fbx.objects 
{
	import net.morocoshi.common.loaders.fbx.attributes.FBXLightAttribute;
	import net.morocoshi.common.loaders.fbx.FBXNode;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class FBXLight extends FBXObject 
	{
		public var attribute:FBXLightAttribute;
		static public const OMNI:int = 0;
		static public const DIRECTIONAL:int = 1;
		static public const SPOT:int = 2;
		
		public function FBXLight(node:FBXNode = null) 
		{
			super(node);
		}
		
		override public function parse(node:FBXNode):void 
		{
			super.parse(node);
			
			rotation.x -= Math.PI * 0.5;
		}
		
	}

}