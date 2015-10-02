package net.morocoshi.moja3d.shaders.render 
{
	import net.morocoshi.moja3d.config.LightSetting;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ランバートシェーディング
	 * 
	 * @author tencho
	 */
	public class LambertShader extends MaterialShader 
	{
		public function LambertShader() 
		{
			super();
			
			requiredAttribute.push(VertexAttribute.NORMAL);
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "LambertShader:";
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
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			fragmentConstants.number = true;
			fragmentConstants.ambient = true;
			fragmentConstants.lights = true;
			fragmentConstants.cameraPosition = true;
			
			fragmentCode.addCode(
				"var $total",
				"var $brightness",
				
				//環境光を加算
				"$total.w = @1",
				"$brightness.w = @1",
				"$total.xyz = @ambientColor.xyz",
				"$total.xyz *= @ambientColor.www"
			);
			
			var i:int;
			
			//点光源を加算
			for (i = 0; i < LightSetting.numOmniLights; i++)
			{
				fragmentCode.addCode("var $temp");
				var omniPosition:String = "@omniPosition" + i;
				var omniData:String = "@omniData" + i;
				var omniColor:String = "@omniColor" + i;
				fragmentCode.addCode(
					"$temp.xyz = " + omniPosition + ".xyz - #wpos.xyz",
					"$temp.xyz = pow($temp.xyz, @2)",
					"$temp.x += $temp.y",
					"$temp.x += $temp.z",
					"$temp.x = sqt($temp.x)",
					"$temp.x = " + omniData + ".x - $temp.x",
					"$temp.x /= " + omniData + ".y",
					"$temp.x = sat($temp.x)",
					
					"$brightness.xyz = " + omniPosition + ".xyz",
					"$brightness.xyz -= #wpos.xyz",
					"$brightness.xyz = nrm($brightness.xyz)",
					"$brightness.xyz = dp3($normal.xyz, $brightness.xyz)",//ライトの向きとのドット積
					"$brightness.xyz = sat($brightness.xyz)",//0～1にする
					"$brightness.xyz *= $temp.xxx",//距離による強度
					"$brightness.xyz *= " + omniColor + ".xyz",//明るさに平行光源カラーを乗算
					"$brightness.xyz *= " + omniColor + ".www"//明るさに平行光源強度を乗算
				)
				/*
				if (i < 3)
				{
					var xyz:String = ["x", "y", "z"][i];
					fragmentCode.addCode("$brightness.xyz *= $common." + xyz)//明るさに影の強度を乗算
				}
				*/
				fragmentCode.addCode("$total.xyz += $brightness.xyz");
			}
			
			//平行光源を加算
			for (i = 0; i < LightSetting.numDirectionalLights; i++) 
			{
				var lightAxis:String = "@lightAxis" + i;
				var lightColor:String = "@lightColor" + i;
				fragmentCode.addCode(
					"$brightness.xyz = dp3($normal.xyz, " + lightAxis + ".xyz)",//ライトの向きとのドット積
					"$brightness.xyz = sat($brightness.xyz)",//0～1にする
					"$brightness.xyz *= " + lightColor + ".xyz",//明るさに平行光源カラーを乗算
					"$brightness.xyz *= " + lightColor + ".www"//明るさに平行光源強度を乗算
				)
				if (i < 3)
				{
					var xyz1:String = ["x", "y", "z"][i];
					fragmentCode.addCode("$brightness.xyz *= $common." + xyz1)//明るさに影の強度を乗算
				}
				fragmentCode.addCode("$total.xyz += $brightness.xyz");
			}
			
			fragmentCode.addCode(
				"$output.xyz *= $total.xyz"
			);
		}
		
		override public function clone():MaterialShader 
		{
			var shader:LambertShader = new LambertShader();
			return shader;
		}
		
	}

}