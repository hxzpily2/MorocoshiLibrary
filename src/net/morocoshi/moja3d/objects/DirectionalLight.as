package net.morocoshi.moja3d.objects 
{
	import net.morocoshi.moja3d.materials.preset.FillMaterial;
	import net.morocoshi.moja3d.materials.TriangleFace;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.primitives.Cube;
	
	use namespace moja3d;
	
	/**
	 * ...
	 * 
	 * @author ...
	 */
	public class DirectionalLight extends Light3D 
	{
		public function DirectionalLight(rgb:uint, intensity:Number) 
		{
			super(rgb, intensity);
		}
		
		override public function reference():Object3D 
		{
			var result:DirectionalLight = new DirectionalLight(getColor(), intensity);
			super.referenceProperties(result);
			return result;
		} 
		override public function clone():Object3D 
		{
			var result:DirectionalLight = new DirectionalLight(getColor(), intensity);
			super.cloneProperties(result);
			return result;
		}
		
	}

}