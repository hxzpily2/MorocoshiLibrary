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
		public var version:uint;
		public var profile:String;
		public var constantsLimit:Object;
		public var maxTokens:int;
		
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
					break;
				case "standard":
				case "standardConstrained":
				case "standardExtended":
					version = 2;
					constantsLimit[Context3DProgramType.VERTEX] = 250;
					constantsLimit[Context3DProgramType.FRAGMENT] = 64;
					maxTokens = 1024;
					break;
			}
			
			
		}
		
	}

}