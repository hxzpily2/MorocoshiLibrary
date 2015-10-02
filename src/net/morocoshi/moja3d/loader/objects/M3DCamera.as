package net.morocoshi.moja3d.loader.objects 
{
	/**
	 * ...
	 * @author tencho
	 */
	public class M3DCamera extends M3DObject 
	{
		public var width:Number = 0;
		public var height:Number = 0;
		public var fovX:Number = 80 / 180 * Math.PI;
		public var fovY:Number = 60 / 180 * Math.PI;
		public var zNear:Number = NaN;
		public var zFar:Number = NaN;
		
		public function M3DCamera() 
		{
		}
		
	}

}