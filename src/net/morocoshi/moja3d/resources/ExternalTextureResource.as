package net.morocoshi.moja3d.resources 
{
	import flash.display3D.Context3D;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class ExternalTextureResource extends ImageTextureResource 
	{
		public var path:String;
		
		public function ExternalTextureResource(path:String) 
		{
			super(null);
			this.path = path;
		}
		
		override public function toString():String 
		{
			return "[" + getQualifiedClassName(this).split("::")[1] + " " + path + "]";
		}
		
	}

}