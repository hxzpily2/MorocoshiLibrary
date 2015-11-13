package net.morocoshi.moja3d.resources 
{
	import net.morocoshi.moja3d.shaders.ShaderList;
	import net.morocoshi.moja3d.shaders.skin.SkinShader;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class SkinGeometry extends Geometry 
	{
		public var boneIDList:Vector.<int>;
		
		public function SkinGeometry() 
		{
			super();
		}
		
		override public function cloneProperties(target:Resource):void 
		{
			super.cloneProperties(target);
			
			var geometry:SkinGeometry = target as SkinGeometry;
			geometry.boneIDList = boneIDList.concat();
			geometry = null;
		}
		
		override public function clone():Resource 
		{
			var geometry:SkinGeometry = new SkinGeometry();
			cloneProperties(geometry);
			return geometry;
		}
	}

}