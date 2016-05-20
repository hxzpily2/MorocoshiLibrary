package net.morocoshi.moja3d.objects 
{
	/**
	 * 平行光源
	 * 
	 * @author tencho
	 */
	public class DirectionalLight extends Light3D 
	{
		/**
		 * 
		 * @param	rgb	光源色
		 * @param	intensity	光源強度
		 * @param	specularPower	光沢強度
		 */
		public function DirectionalLight(rgb:uint, intensity:Number = 1, specularPower:Number = 1) 
		{
			super(rgb, intensity, specularPower);
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