package net.morocoshi.moja3d.loader 
{
	import flash.utils.ByteArray;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.objects.Object3D;
	
	use namespace moja3d;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class M3DLoadItem 
	{
		public var id:String;
		public var parser:M3DParser;
		public var includeTo:Object3D;
		moja3d var data:ByteArray;
		
		public function M3DLoadItem(id:String, data:ByteArray, includeTo:Object3D) 
		{
			this.id = id;
			this.data = data;
			this.includeTo = includeTo;
			parser = new M3DParser();
		}
		
	}

}