package net.morocoshi.moja3d.view 
{
	import flash.system.Capabilities;
	import flash.system.System;
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class DriverInfo 
	{
		private var _isSoftware:Boolean;
		private var _softwareType:String;
		
		/**[パブリッシュ設定]で[ハードウェアアクセラレーション]が正しく選ばれていない。*/
		static public const USER_DISABLED:String = "userDisabled";
		/**ドライバが既知の問題によりブラックリストに入れられている。ドライバを更新すれば解決します。*/
		static public const OLD_DRIVER:String = "oldDriver";
		/**ドライバの能力的にハードウェアが使えないか、ハードウェアグラフィックスの初期化で問題が生じている。*/
		static public const UNAVAILABLE:String = "unavailable";
		/**コンテンツからStage3D.requestContext3D()メソッドにより、Stage3Dのソフトウェアレンダリングが求められている。*/
		static public const EXPLICIT:String = "explicit";
		/**既に破棄されている場合*/
		static public const DISPOSED:String = "Disposed";
		
		public function DriverInfo(info:String = null) 
		{
			if (info)
			{
				parse(info);
			}
		}
		
		public function parse(info:String):void 
		{
			_isSoftware = (info.indexOf("Software") == 0);
			if (_isSoftware)
			{
				var param:String = info.substr(9);
				switch(param)
				{
					case "Hw_disabled=userDisabled"	: _softwareType = USER_DISABLED; break;
					case "Hw_disabled=oldDriver"	: _softwareType = OLD_DRIVER; break;
					case "Hw_disabled=unavailable"	: _softwareType = UNAVAILABLE; break;
					case "Hw_disabled=explicit"		: _softwareType = EXPLICIT; break;
				}
			}
		}
		
		public function get isSoftware():Boolean 
		{
			return _isSoftware;
		}
		
		public function get softwareType():String 
		{
			return _softwareType;
		}
		
	}

}