package net.morocoshi.moja3d.shaders.render 
{
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.config.LightSetting;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.AlphaTransform;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	use namespace moja3d;
	
	/**
	 * 光沢シェーダー。フレネル効果にも対応。
	 * 
	 * @author tencho
	 */
	public class SpecularShader extends MaterialShader 
	{
		private var specularConst:AGALConstant;
		private var _alpha:Number;
		private var _power:Number;
		private var _protectTransparent:Boolean;
		private var _protectReverse:Boolean;
		private var _fresnel:Boolean;
		
		/**
		 * 
		 * @param	power	この値が大きいほど光沢は鋭くなる。10～100くらい
		 * @param	alpha	光沢の強度
		 * @param	fresnel	フレネル効果を適用するか
		 * @param	protectTransparent	trueで元の透明度を変化させないようにする
		 * @param	protectReverse
		 */
		public function SpecularShader(power:int, alpha:Number, fresnel:Boolean, protectTransparent:Boolean = true, protectReverse:Boolean = false) 
		{
			super();
			
			requiredAttribute.push(VertexAttribute.NORMAL);
			
			_power = power;
			_alpha = alpha;
			_fresnel = fresnel;
			_protectTransparent = protectTransparent;
			_protectReverse = protectReverse;
			
			requiredAttribute.push(VertexAttribute.NORMAL);
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "SpecularShader:" + _fresnel + "_" + _protectTransparent + "_" + _protectReverse;
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaTransform = _protectTransparent? AlphaTransform.UNCHANGE : AlphaTransform.SET_MIXTURE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
			
			specularConst = fragmentCode.addConstantsFromArray("@specularPower", [_power, _alpha, 0, 0]);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			var i:int;
			
			fragmentConstants.number = true;
			fragmentConstants.cameraPosition = true;
			fragmentConstants.lights = true;
			
			fragmentCode.addCode([
				//ピクセルから視線へのベクトル（正規化）
				"var $eye",
				"var $light",
				"var $half",
				
				"$eye.xyz = @cameraPosition.xyz - #wpos.xyz",
				"$eye.xyz = nrm($eye.xyz)"
			]);
			
			var xyz:String;
			
			for (i = 0; i < LightSetting._numOmniLights; i++)
			{
				xyz = ["x", "y", "z"][i];
				var omniPosition:String = "@omniPosition" + i;
				var omniData:String = "@omniData" + i;
				var omniColor:String = "@omniColor" + i;
				fragmentCode.addCode([
					"$light.xyz = " + omniPosition + ".xyz - #wpos.xyz",
					"$light.xyz = pow($light.xyz, @2)",
					"$light.w = $light.x + $light.y",
					"$light.w += $light.z",
					"$light.w = sqt($light.w)",
					"$light.w = " + omniData + ".x - $light.w",
					"$light.w /= " + omniData + ".y",
					"$light.w = sat($light.w)",
					
					//ピクセルからライトへのベクトル（正規化）
					"$light.xyz = " + omniPosition + ".xyz",
					"$light.xyz -= #wpos.xyz",
					"$light.xyz = nrm($light.xyz)",
					
					//視線へのベクトル+ライトへのベクトルを正規化＝ハーフベクトル
					"$half.xyz = $eye.xyz + $light.xyz",
					"$half.xyz = nrm($half.xyz)",
					
					"$half.w = dp3($normal.xyz, $half.xyz)",//法線とハーフベクトルのドット積
					"$half.w = sat($half.w)",//0～1にする
					"$half.w = pow($half.w, @specularPower.x)",//累乗
					"$half.w *= @specularPower.y",//スペキュラ強度
					"$half.w *= " + omniColor + ".w",//ライトの強度
					"$half.w *= " + omniData + ".z",//ライトのスペキュラ強度
					"$half.w *= $light.w",//距離による減退
					"$half.w *= $common." + xyz//影の強度
				]);
				
				//ライトと法線の角度の関係を調べて、逆から当たっていたら強度を0にしたい
				//ライトへのベクトルと法線ベクトルの向きが90を超えるなら強度を0に
				if (_protectReverse)
				{
					fragmentCode.addCode([
						"$light.w = dp3($light.xyz, $normal.xyz)",
						"$light.w = sat($light.w)",//0-1
						"$half.w *= $light.w"
					]);
				}
				
				fragmentCode.addCode([
					"$half.xyz = $half.www * " + omniColor + ".xyz"//ライトカラー
				]);
				
				if (_fresnel)
				{
					fragmentCode.addCode([
						"$half.xyz *= $common.w"//フレネル反射
					]);
				}
				
				var code:String = _protectTransparent? "$output.xyz += $half.xyz" : "$output.xyzw += $half.xyzw";
				fragmentCode.addCode([code]);
			}
			
			for (i = 0; i < LightSetting._numDirectionalLights; i++) 
			{
				xyz = ["x", "y", "z"][i];
				var lightAxis:String = "@lightAxis" + i;
				var lightColor:String = "@lightColor" + i;
				fragmentCode.addCode([
					//ピクセルからライトへのベクトル（正規化）
					"$light.xyz = " + lightAxis + ".xyz",
					"$light.xyz = nrm($light.xyz)",
					
					//視線へのベクトル+ライトへのベクトルを正規化＝ハーフベクトル
					"$half.xyz = $eye.xyz + $light.xyz",
					"$half.xyz = nrm($half.xyz)",
					
					"$half.w = dp3($normal.xyz, $half.xyz)",//法線とハーフベクトルのドット積
					"$half.w = sat($half.w)",//0～1にする
					"$half.w = pow($half.w, @specularPower.x)",//累乗
					"$half.w *= @specularPower.y",//スペキュラ強度
					"$half.w *= " + lightColor + ".w",//ライトの強度
					"$half.w *= " + lightAxis + ".w",//ライトのスペキュラ強度
					"$half.w *= $common." + xyz//影の強度
				]);
				
				//ライトと法線の角度の関係を調べて、逆から当たっていたら強度を0にしたい
				//ライトへのベクトルと法線ベクトルの向きが90を超えるなら強度を0に
				if (_protectReverse)
				{
					fragmentCode.addCode([
						"$light.w = dp3($light.xyz, $normal.xyz)",
						"$light.w = sat($light.w)",//0-1
						"$half.w *= $light.w"
					]);
				}
				
				fragmentCode.addCode([
					"$half.xyz = $half.www * " + lightColor + ".xyz"//ライトカラー
				]);
				
				if (_fresnel)
				{
					fragmentCode.addCode([
						"$half.xyz *= $common.w"//フレネル反射
					]);
				}
				
				var code2:String = _protectTransparent? "$output.xyz += $half.xyz" : "$output.xyzw += $half.xyzw";
				fragmentCode.addCode([code2]);
			}
		}
		
		public function get alpha():Number 
		{
			return _alpha;
		}
		
		public function set alpha(value:Number):void 
		{
			_alpha = value;
			specularConst.y = value;
		}
		
		public function get power():Number 
		{
			return _power;
		}
		
		public function set power(value:Number):void 
		{
			_power = value;
			specularConst.x = value;
		}
		
		public function get protectTransparent():Boolean 
		{
			return _protectTransparent;
		}
		
		public function set protectTransparent(value:Boolean):void 
		{
			_protectTransparent = value;
			updateShaderCode();
		}
		
		public function get protectReverse():Boolean 
		{
			return _protectReverse;
		}
		
		public function set protectReverse(value:Boolean):void 
		{
			_protectReverse = value;
			updateShaderCode();
		}
		
		public function get fresnel():Boolean 
		{
			return _fresnel;
		}
		
		public function set fresnel(value:Boolean):void 
		{
			_fresnel = value;
			updateShaderCode();
		}
		
		override public function clone():MaterialShader 
		{
			return new SpecularShader(_power, _alpha, _fresnel, _protectTransparent, _protectReverse);
		}
		
	}

}