package net.morocoshi.common.loaders.asset
{
	import flash.display.AVM1Movie;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.media.Sound;
	import flash.utils.ByteArray;
	import net.morocoshi.common.video.flv.FLV;
	/**
	 * ...
	 * @author	unknown
	 */
	public class AssetItem
	{
		public var id:String = "";
		public var src:String = "";
		public var type:String = "";
		public var rate:Number = 1;
		public var progress:Number = 0;
		public var success:Boolean = false;
		public var strict:Boolean = true;
		public var image:BitmapData;
		public var clip:MovieClip;
		public var avm1:AVM1Movie;
		public var text:String;
		public var flv:FLV;
		public var sound:Sound;
		public var xml:XML;
		public var bytes:ByteArray;
		
		public function AssetItem()
		{
		}
		
	}
	
}