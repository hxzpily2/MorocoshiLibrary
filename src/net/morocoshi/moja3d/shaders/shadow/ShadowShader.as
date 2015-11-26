package net.morocoshi.moja3d.shaders.shadow
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.config.LightSetting;
	import net.morocoshi.moja3d.materials.Mipmap;
	import net.morocoshi.moja3d.materials.Smoothing;
	import net.morocoshi.moja3d.materials.Tiling;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	use namespace moja3d;
	
	/**
	 * デプスシャドウの濃度を計算する
	 * 
	 * @author tencho
	 */
	public class ShadowShader extends MaterialShader 
	{
		private var _mainSamples:int;
		private var _wideSamples:int;
		
		private var _syncLight:Boolean;
		private var _intensity:Number;
		private var _depthBias:Number;
		
		private var _mainBlur:Number;
		private var _wideBlur:Number;
		
		private var _mainNear:Number;
		private var _mainFar:Number;
		
		private var _useWideShadow:Boolean;
		private var _wideNear:Number;
		private var _wideFar:Number;
		private var _wideDepthBias:Number;
		
		private var depthBlurConst:AGALConstant;
		private var distanceConst:AGALConstant;
		private var fadeConst:AGALConstant;
		private var numConst:AGALConstant;
		private var _fadeType:String;
		
		/**
		 * @param	syncLight	シャドウパラメータをシャドウライトと同期させる
		 * @param	fadeType	影のフェードタイプ。ShadowFadeTypeクラスを参照。
		 */
		public function ShadowShader(syncLight:Boolean = true, fadeType:String = "clipBorder")
		{
			super();
			
			if (fadeType == ShadowFadeType.RADIAL_GRADIENT)
			{
				throw new Error("円形グラデーションタイプは未実装です！")
			}
			
			_syncLight = syncLight;
			_fadeType = fadeType;
			
			checkSample();
			_intensity = 1;
			_wideNear = _mainNear = 10000;
			_wideFar = _mainFar = 10000;
			
			_depthBias = _wideDepthBias = 0.005;
			_useWideShadow = false;
			
			hasShadowElement = true;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			calcBlur();
			updateShaderCode();
		}
		
		private function checkSample():void 
		{
			if (_mainSamples < 1) _mainSamples = 1;
			if (_wideSamples < 1) _wideSamples = 1;
			if (_mainSamples > 9) _mainSamples = 9;
			if (_wideSamples > 9) _wideSamples = 9;
		}
		
		override public function getKey():String 
		{
			return "ShadowShader:" + _fadeType + "_" + LightSetting._numDirectionalShadow + "_" + _mainSamples + "_" + _wideSamples;
		}
		
		private function calcBlur():void 
		{
			//ぼかさない場合はループをしない
			depthBlurConst.y = _mainBlur;
			depthBlurConst.w = _wideBlur;
			numConst.x = (_mainBlur == 0)? 1 : _mainSamples;
			numConst.y = (_wideBlur == 0)? 1 : _wideSamples;
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaMode = AlphaMode.NONE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
			distanceConst = fragmentCode.addConstantsFromArray("@S256", [256, 256 * 256, 0.00001, _intensity]);
			numConst = fragmentCode.addConstantsFromArray("@shadowBlurNum", [_mainSamples, _wideSamples, 0.5, -0.5]);
			depthBlurConst = fragmentCode.addConstantsFromArray("@depthBlur", [_depthBias, _mainBlur, _wideDepthBias, _wideBlur]);
			fadeConst = fragmentCode.addConstantsFromArray("@shadowFade", [0, 0, 0, 0]);
			calcConstants();
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			vertexConstants.shadow = true;
			fragmentConstants.shadow = true;
			fragmentConstants.number = true;
			fragmentConstants.cameraPosition = true;
			
			var i:int;
			var g:int;
			
			fragmentCode.addCode([
				"var $lightZ",
				"var $result",
				"var $power",
				"$result.xy = @0_0"
			]);
			
			for (i = 0; i < LightSetting._numDirectionalShadow; i++) 
			{
				var xyz:String = ["x", "y", "z"][i];
				var numLightLeyers:int = _useWideShadow? 2 : 1;
				
				//平行光源を加算
				
				//デプス値をフラグメントに送る準備
				for (g = 0; g < numLightLeyers; g++)
				{
					var vf:String = "#shadowData" + i + "_" + g;
					var lightView:String = "@shadowViewMatrix" + i + "_" + g;
					vertexCode.addCode([
						"var $lightPos",
						"$lightPos = m44($wpos, " + lightView + ")",//ライトビュー&プロジェクション行列で変換
						vf + " = $lightPos"
					]);
				}
				
				//
				for (g = 0; g < numLightLeyers; g++)
				{
					var vt:String = "#shadowData" + i + "_" + g;
					var xyz2:String = ["x", "y"][g];
					var xyz3:String = ["z", "w"][g];
					var shadowMap:String = "&shadowMap" + i + "_" + g;
					var xz:String = ["x", "z"][g];
					var yw:String = ["y", "w"][g];
					var numSample:int = (g == 0)? _mainSamples : _wideSamples;
					for (var j:int = 0; j < numSample; j++) 
					{
						var slideCode:String = "";
						if (j == 1) slideCode = "$lightUV.x += @depthBlur." + yw;
						if (j == 2) slideCode = "$lightUV.x -= @depthBlur." + yw;
						if (j == 3) slideCode = "$lightUV.y += @depthBlur." + yw;
						if (j == 4) slideCode = "$lightUV.y -= @depthBlur." + yw;
						
						if (j == 5) slideCode = "$lightUV.xy -= @depthBlur." + yw;
						if (j == 6) slideCode = "$lightUV.xy += @depthBlur." + yw;
						if (j == 7)
						{
							slideCode = "$lightUV.x += @depthBlur." + yw;
							slideCode = "$lightUV.y -= @depthBlur." + yw;
						}
						if (j == 8)
						{
							slideCode = "$lightUV.x -= @depthBlur." + yw;
							slideCode = "$lightUV.y += @depthBlur." + yw;
						}
						
						var tag:String = getTextureTag(Smoothing.NEAREST, Mipmap.NOMIP, Tiling.CLAMP, "");
						fragmentCode.addCode([
							"var $zdepth",
							//ライト空間でのデプス値
							"$zdepth.x = " + vt + ".z / " + vt + ".w",
							//ライト空間のスクリーン座標をUV座標に変換
							"var $lightUV",
							"$lightUV.xy = " + vt + ".xy / " + vt + ".w",
							slideCode,
							//"$lightUV.y = neg($lightUV.y)",
							"$lightUV.xy *= @shadowBlurNum.zw",
							//"$lightUV.xy *= @0.5",
							"$lightUV.xy += @0.5",
							
							//RGB値からデプス値を復元する
							"$lightZ.xyz = tex($lightUV.xy, " + shadowMap + " " + tag + ")",
							
							"$lightZ.y /= @S256.x",
							"$lightZ.z /= @S256.y",
							"$lightZ.x += $lightZ.y",
							"$lightZ.x += $lightZ.z",
							
							"$lightZ.x += @depthBlur." + xz,//マッハバンド対策にオフセット
							"$lightZ.x = sge($zdepth.x, $lightZ.x)",//明暗比較
							
							"$result." + xyz2 + " += $lightZ.x"
						]);
					}
					if (_fadeType == ShadowFadeType.CLIP_BORDER)
					{
						fragmentCode.addCode([
							//UVが0-1の外の影を消す
							"$lightUV.xy = " + vt + ".xy / " + vt + ".w",
							"$lightUV.xy = abs($lightUV.xy)",
							"$lightUV.z = max($lightUV.x, $lightUV.y)",
							"$lightUV.z += @S256.z",
							"$power." + xyz2 + " = sge(@1, $lightUV.z)",
							"$result." + xyz2 + " *= $power." + xyz2
						]);
					}
					if (_fadeType == ShadowFadeType.DIAMOND_GRADIENT)
					{
						fragmentCode.addCode([
							//UVが0-1の外の影を消す
							"$lightUV.xy = " + vt + ".xy / " + vt + ".w",
							"$lightUV.xy = abs($lightUV.xy)",
							"$lightUV.z = max($lightUV.x, $lightUV.y)",
							"$lightUV.z = $lightUV.z - @shadowFade.x",
							"$lightUV.z = $lightUV.z / @shadowFade.y",
							"$lightUV.z = @1 - $lightUV.z",
							"$power." + xyz2 + " = sat($lightUV.z)",
							//"$lightUV.z += @S256.z",
							//"$power." + xyz2 + " = sge(@1, $lightUV.z)",
							"$result." + xyz2 + " *= $power." + xyz2
						]);
					}
				}
				
				if (_fadeType == ShadowFadeType.CASCADE)
				{
					//カメラ平面からの距離
					fragmentCode.addCode([
						"$power.w = #spos.w"
					]);
					
					//近い距離の割合0～1
					fragmentCode.addCode([
						"$power.x = $power.w - @shadowFade.x",
						"$power.x /= @shadowFade.y",
						"$power.x = sat($power.x)",
						"$power.y = @1 - $power.x"
					]);
				}
				
				if (_useWideShadow)
				{
					//遠景の影がある場合
					if (_fadeType == ShadowFadeType.CASCADE)
					{
						fragmentCode.addCode([
							//遠い距離の割合0～1
							"$power.z = $power.w - @shadowFade.z",
							"$power.z /= @shadowFade.w",
							"$power.z = sat($power.z)",
							"$power.w = @1 - $power.z",
							
							"$result.xy /= @shadowBlurNum.xy",//ぼかし加算分割る
							"$result.xy *= $power.yx",
							"$result.x += $result.y",//近遠クロスフェード
							"$result.x *= $power.w"//遠景フェードを乗算
						]);
					}
					if (_fadeType == ShadowFadeType.CLIP_BORDER || _fadeType == ShadowFadeType.DIAMOND_GRADIENT)
					{
						//近遠クロスフェード
						fragmentCode.addCode([
							"$result.xy /= @shadowBlurNum.xy",//ぼかし加算分割る
							//"$result.xy *= $power.yx",
							"$result.z = @1 - $power.x",
							"$result.y *= $result.z",
							"$result.x += $result.y"
							//"$result.x *= $power.w"//遠景フェードを乗算
						]);
					}
				}
				else
				{
					//近景の影のみの場合
					fragmentCode.addCode([
						"$result.x /= @shadowBlurNum.x"//ぼかし加算分割る
					]);
					if (_fadeType == ShadowFadeType.CASCADE)
					{
						fragmentCode.addCode([
							"$result.x *= $power.y"//近景フェードを乗算
						]);
					}
				}
				
				fragmentCode.addCode([
					"$result.x *= @S256.w",//影の強度
					"$common." + xyz + " = @1 - $result.x"
				]);
			}
		}
		
		/**
		 * 近景シャドウのフェード範囲用レジスタの更新
		 */
		private function calcConstants():void 
		{
			if (_fadeType == ShadowFadeType.CASCADE)
			{
				fadeConst.x = _mainNear;
				fadeConst.y = _mainFar - _mainNear;
				fadeConst.z = _wideNear;
				fadeConst.w = _wideFar - _wideNear;
			}
			else
			{
				fadeConst.x = _mainNear / _mainFar;
				fadeConst.y = 1 - fadeConst.x;
				fadeConst.z = _wideFar / _wideNear;
				fadeConst.w = 1 - fadeConst.z;
			}
		}
		
		override public function clone():MaterialShader 
		{
			var result:ShadowShader = new ShadowShader(_syncLight);
			result.mainBlur = _mainBlur;
			result.wideBlur = _wideBlur;
			result.mainSamples = _mainSamples;
			result.wideSamples = _wideSamples;
			result.fadeType = _fadeType;
			return result;
		}
		
		public function get intensity():Number 
		{
			return _intensity;
		}
		
		public function set intensity(value:Number):void 
		{
			if (_intensity == value) return;
			
			_intensity = value;
			distanceConst.w = _intensity;
		}
		
		public function get depthBias():Number 
		{
			return _depthBias;
		}
		
		public function set depthBias(value:Number):void 
		{
			if (_depthBias == value) return;
			
			_depthBias = value;
			depthBlurConst.x = _depthBias;
		}
		
		public function get mainBlur():Number 
		{
			return _mainBlur;
		}
		
		public function set mainBlur(value:Number):void 
		{
			if (_mainBlur == value) return;
			
			depthBlurConst.y = _mainBlur = value;
			calcBlur();
			updateShaderCode();
		}
		
		public function get mainNear():Number 
		{
			return _mainNear;
		}
		
		public function set mainNear(value:Number):void 
		{
			if (_mainNear == value) return;
			
			_mainNear = value;
			calcConstants();
		}
		
		public function get mainFar():Number 
		{
			return _mainFar;
		}
		
		public function set mainFar(value:Number):void 
		{
			if (_mainFar == value) return;
			
			_mainFar = value;
			calcConstants();
		}
		
		public function get wideNear():Number 
		{
			return _wideNear;
		}
		
		public function set wideNear(value:Number):void 
		{
			if (_wideNear == value) return;
			
			_wideNear = value;
			calcConstants();
		}
		
		public function get wideFar():Number 
		{
			return _wideFar;
		}
		
		public function set wideFar(value:Number):void 
		{
			if (_wideFar == value) return;
			
			_wideFar = value;
			calcConstants();
		}
		
		public function get wideDepthBias():Number 
		{
			return _wideDepthBias;
		}
		
		public function set wideDepthBias(value:Number):void 
		{
			if (_wideDepthBias == value) return;
			
			_wideDepthBias = value;
			depthBlurConst.z = _wideDepthBias;
			
		}
		
		public function get wideBlur():Number 
		{
			return _wideBlur;
		}
		
		public function set wideBlur(value:Number):void 
		{
			if (_wideBlur == value) return;
			
			_wideBlur = value;
			calcBlur();
			updateShaderCode();
		}
		
		public function get useWideShadow():Boolean 
		{
			return _useWideShadow;
		}
		
		public function set useWideShadow(value:Boolean):void 
		{
			if (_useWideShadow == value) return;
			
			_useWideShadow = value;
			updateShaderCode();
		}
		
		public function get syncLight():Boolean 
		{
			return _syncLight;
		}
		
		public function set syncLight(value:Boolean):void 
		{
			_syncLight = value;
		}
		
		public function get mainSamples():int 
		{
			return _mainSamples;
		}
		
		public function set mainSamples(value:int):void 
		{
			if (_mainSamples == value) return;
			
			_mainSamples = value;
			calcBlur();
			updateShaderCode();
		}
		
		public function get wideSamples():int 
		{
			return _wideSamples;
		}
		
		public function set wideSamples(value:int):void 
		{
			if (_wideSamples == value) return;
			
			_wideSamples = value;
			calcBlur();
			updateShaderCode();
		}
		
		public function get fadeType():String 
		{
			return _fadeType;
		}
		
		public function set fadeType(value:String):void 
		{
			_fadeType = value;
			updateShaderCode();
		}
		
	}

}