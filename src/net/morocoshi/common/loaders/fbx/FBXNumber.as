package net.morocoshi.common.loaders.fbx 
{
	/**
	 * ...
	 * @author tencho
	 */
	public class FBXNumber 
	{
		public var value:Number;
		
		public function FBXNumber(value:Number) 
		{
			this.value = value;
		}
		
		public function toString():String
		{
			return "*" + value.toString();
		}
		
	}

}