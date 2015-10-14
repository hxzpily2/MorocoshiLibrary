package net.morocoshi.moja3d.config 
{
	import net.morocoshi.moja3d.moja3d;
	
	use namespace moja3d;
		
	/**
	 * ライト関連の設定
	 * 
	 * @author ...
	 */
	public class LightSetting 
	{
		/**平行光源の最大数*/
		static moja3d var _numDirectionalLights:int = 2;
		/**点光源の最大数*/
		static moja3d var _numOmniLights:int = 0;
		/**平行光源のデプスシャドウの最大数*/
		static moja3d var _numDirectionalShadow:int = 1;
		/**デフォルトでメッシュオブジェクトが影を落とすかどうか*/
		static moja3d var _defaultCastShadow:Boolean = true;
		/**デフォルトでメッシュオブジェクトが光筋を伸ばすかどうか*/
		static moja3d var _defaultCastLight:Boolean = false;
		
		/**Scene3Dがレンダリングされたかどうか*/
		static moja3d var renderInitialized:Boolean = false;
		
		static public function get defaultCastLight():Boolean 
		{
			return _defaultCastLight;
		}
		
		static public function set defaultCastLight(value:Boolean):void 
		{
			_defaultCastLight = value;
		}
		
		static public function get defaultCastShadow():Boolean 
		{
			return _defaultCastShadow;
		}
		
		static public function set defaultCastShadow(value:Boolean):void 
		{
			_defaultCastShadow = value;
		}
		
		static public function get numDirectionalShadow():int 
		{
			return _numDirectionalShadow;
		}
		
		static public function set numDirectionalShadow(value:int):void 
		{
			if (renderInitialized)
			{
				throw new Error("デプスシャドウ数はシーンの初回レンダリング前にしか設定できません！");
			}
			if (value >= 4)
			{
				throw new Error("デプスシャドウは3つが上限です！");
			}
			
			_numDirectionalShadow = value;
		}
		
		static public function get numOmniLights():int 
		{
			return _numOmniLights;
		}
		
		static public function set numOmniLights(value:int):void 
		{
			if (renderInitialized)
			{
				throw new Error("点光源数はシーンの初回レンダリング前にしか設定できません！");
			}
			_numOmniLights = value;
		}
		
		static public function get numDirectionalLights():int 
		{
			return _numDirectionalLights;
		}
		
		static public function set numDirectionalLights(value:int):void 
		{
			if (renderInitialized)
			{
				throw new Error("平行光源数はシーンの初回レンダリング前にしか設定できません！");
			}
			_numDirectionalLights = value;
		}
		
	}

}