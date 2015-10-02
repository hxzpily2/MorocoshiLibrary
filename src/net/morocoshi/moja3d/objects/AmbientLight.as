package net.morocoshi.moja3d.objects 
{
	/**
	 * ...
	 * 
	 * @author ...
	 */
	public class AmbientLight extends Light3D 
	{
		
		public function AmbientLight(rgb:uint, intensity:Number) 
		{
			super(rgb, intensity);
		}
		
		override public function clone():Object3D 
		{
			var result:AmbientLight = new AmbientLight(0xffffff, 1);
			super.cloneProperties(result);
			return result;
		}
		
	}

}