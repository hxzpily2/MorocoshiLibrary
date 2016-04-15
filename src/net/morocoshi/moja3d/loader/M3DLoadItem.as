package net.morocoshi.moja3d.loader 
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	import mx.core.ByteArrayAsset;
	import net.morocoshi.moja3d.objects.Object3D;
	/**
	 * ...
	 * @author tencho
	 */
	public class M3DLoadItem 
	{
		public var container:Object3D;
		public var parser:M3DParser;
		public var data:ByteArray;
		public var id:String;
		
		public function M3DLoadItem(id:String, data:ByteArray, container:Object3D) 
		{
			this.id = id;
			this.data = data;
			this.container = container;
			parser = new M3DParser();
		}
		
	}

}