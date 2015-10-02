package net.morocoshi.moja3d.resources 
{
	import flash.display3D.Context3DTextureFormat;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class ATFData 
	{
		public var data:ByteArray;
		public var format:String;
		public var width:int;
		public var height:int;
		public var isCubeMap:Boolean;
		private var _hasAlpha:Boolean;
		
		public function ATFData(data:ByteArray) 
		{
			this.data = data;
			data.position = data[6] == 255? 12 : 6;
			var type:uint = data.readByte();
			switch (type & 0x7f)
			{
				case 0:
				case 1:
					format = Context3DTextureFormat.BGRA;
					break;
				case 2:
				case 3:
					format = Context3DTextureFormat.COMPRESSED;
					break;
				case 4:
				case 5:
					format = Context3DTextureFormat.COMPRESSED_ALPHA;
					break;
				default:
					throw new Error("ATFデータを解析できません。");
			}
			
			isCubeMap = (type & ~0x7F) != 0;
			_hasAlpha = (format != Context3DTextureFormat.COMPRESSED);
			
			width = 1 << data.readUnsignedByte();
			height = isCubeMap? width : 1 << data.readUnsignedByte();
			data.position = 0;
		}
		
		public function getSamplingOption():String 
		{
			switch(format)
			{
				case Context3DTextureFormat.BGRA: return "";
				case Context3DTextureFormat.COMPRESSED: return "dxt1";
				case Context3DTextureFormat.COMPRESSED_ALPHA: return "dxt5";
			}
			return "";
		}
		
		public function get hasAlpha():Boolean 
		{
			return _hasAlpha;
		}
		
	}

}