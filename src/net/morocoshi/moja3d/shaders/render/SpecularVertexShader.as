package net.morocoshi.moja3d.shaders.render 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.config.LightSetting;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class SpecularVertexShader extends MaterialShader 
	{
		private var specularConst:AGALConstant;
		private var _alpha:Number;
		private var _power:Number;
		private var _protectReverse:Boolean;
		private var _protectTransparent:Boolean;
		
		/**
		 * 
		 * @param	power
		 * @param	alpha
		 * @param	protectTransparent	trueで元の透明度を変化させないようにする
		 * @param	protectReverse
		 */
		public function SpecularVertexShader(power:int, alpha:Number, protectTransparent:Boolean = true, protectReverse:Boolean = false) 
		{
			super();
			
			requiredAttribute.push(VertexAttribute.NORMAL);
			
			_power = power;
			_alpha = alpha;
			_protectReverse = protectReverse;
			_protectTransparent = protectTransparent;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "SpecularVertexShader:" + _protectTransparent + "_" + _protectReverse;
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
			
			specularConst = vertexCode.addConstantsFromArray("@specularPower", [_power, _alpha, 0, 0]);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			var i:int;
			var lightAxis:String;
			var lightColor:String;
			
			vertexConstants.number = true;
			vertexConstants.cameraPosition = true;
			vertexConstants.lights = true;
			
			vertexCode.addCode(
				//テクセルから視線へのベクトル（正規化）
				"var $specular",
				"var $light",
				"var $eye",
				"var $half",
				"var $fade",
				
				"$specular.xyzw = @0",
				//"$specular.xyz = @0_0_0",
				"$eye.xyz = @cameraPosition.xyz - $wpos.xyz",
				"$eye.xyz = nrm($eye.xyz)"
			);
			
			for (i = 0; i < LightSetting.numDirectionalLights; i++) 
			{
				lightAxis = "@lightAxis" + i;
				lightColor = "@lightColor" + i;
				vertexCode.addCode(
					//テクセルからライトへのベクトル（正規化）
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
					"$half.w *= " + lightAxis + ".w"//ライトのスペキュラ強度
				);
				
				//ライトへのベクトルと法線ベクトルの向きが90を超えるなら強度を0に
				//ライトと法線の角度の関係を調べて、逆から当たっていたら強度を0にしたい		
				if (_protectReverse)
				{
					vertexCode.addCode(
						"$light.w = dp3($light.xyz, $normal.xyz)",
						"$light.w = sat($light.w)",//0-1
						"$half.w *= $light.w"
					);
				}
				
				vertexCode.addCode(
					"$half.xyz = $half.www * " + lightColor + ".xyz",//ライトカラー
					"$specular.xyzw += $half.xyzw"
				);
			}
			vertexCode.addCode(
				"#specular = $specular"
			);
			
			var code:String = _protectTransparent? "$output.xyz += #specular.xyz" : "$output.xyzw += #specular.xyzw";
			fragmentCode.addCode(code);
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
		
		public function get protectReverse():Boolean 
		{
			return _protectReverse;
		}
		
		public function set protectReverse(value:Boolean):void 
		{
			_protectReverse = value;
			updateShaderCode();
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
		
		override public function clone():MaterialShader 
		{
			return new SpecularVertexShader(_power, _alpha, _protectTransparent, _protectReverse);
		}
		
	}

}