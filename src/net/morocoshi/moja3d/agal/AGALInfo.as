package net.morocoshi.moja3d.agal 
{
	import flash.display3D.Context3DProgramType;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class AGALInfo 
	{
		/**1ジオメトリが持てる最大頂点データ数*/
		static public const VERTEXDATA_LIMIT:int = 65535;
		/**1ジオメトリが持てる最大頂点インデックス数*/
		static public const VERTEXINDEX_LIMIT:int = 524287;
		public var version:uint;
		public var profile:String;
		public var constantsLimit:Object;
		public var maxTokens:int;
		public var varyingLimit:int;
		public var temporaryLimit:int;
		
		public function AGALInfo(profile:String) 
		{
			this.profile = profile;
			constantsLimit = { };
			switch(profile)
			{
				case "baseline":
				case "baselineConstrained":
				case "baselineExtended":
					version = 1;
					constantsLimit[Context3DProgramType.VERTEX] = 128;
					constantsLimit[Context3DProgramType.FRAGMENT] = 28;
					maxTokens = 200;
					varyingLimit = 8;
					temporaryLimit = 8;
					break;
				case "standard":
				case "standardConstrained":
				case "standardExtended":
					version = 2;
					constantsLimit[Context3DProgramType.VERTEX] = 250;
					constantsLimit[Context3DProgramType.FRAGMENT] = 64;
					maxTokens = 1024;
					varyingLimit = 8;
					temporaryLimit = 26
					break;
			}
			
			
		}
		
	}

}