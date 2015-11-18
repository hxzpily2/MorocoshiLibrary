package net.morocoshi.moja3d.objects 
{
	/**
	 * 平行光源
	 * 
	 * @author tencho
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