package net.morocoshi.moja3d.objects 
{
	/**
	 * 全方位から当たる環境光
	 * 
	 * @author tencho
	 */
	public class AmbientLight extends Light3D 
	{
		/**
		 * 
		 * @param	rgb	光源色
		 * @param	intensity	光源強度
		 */
		public function AmbientLight(rgb:uint, intensity:Number = 1) 
		{
			super(rgb, intensity);
		}
		
		override public function clone():Object3D 
		{
			//色と強度は継承元クラスでコピーされるので適当でいい
			var result:AmbientLight = new AmbientLight(0xffffff, intensity);
			super.cloneProperties(result);
			return result;
		}
		
	}

}