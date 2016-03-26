package net.morocoshi.moja3d.shaders.render 
{
	import net.morocoshi.moja3d.config.LightSetting;
	import net.morocoshi.moja3d.renderer.RenderLayer;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ランバートシェーディング
	 * 
	 * @author tencho
	 */
	public class HalfLambertShader extends MaterialShader 
	{
		private var _vertexMode:Boolean;
		
		public function HalfLambertShader() 
		{
			super();
			
			_vertexMode = false;
			requiredAttribute.push(VertexAttribute.NORMAL);
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "LambertShader:" + String(_vertexMode);
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaMode = AlphaMode.UNKNOWN;
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
			
			if (_vertexMode)
			{
				updateVertexShader();
			}
			else
			{
				updateFragmentShader();
			}
		}
		
		private function updateFragmentShader():void
		{
			fragmentConstants.number = true;
			fragmentConstants.ambient = true;
			fragmentConstants.lights = true;
			
			fragmentCode.addCode([
				"var $total",
				"var $brightness",
				
				//環境光を加算
				"$total.xyz = @ambientColor.xyz",
				"$total.xyz *= @ambientColor.www"
			]);
			
			for (var i:int = 0; i < LightSetting.numDirectionalLights; i++) 
			{
				var xyz:String = ["x", "y", "z"][i];
				var lightAxis:String = "@lightAxis" + i;
				var lightColor:String = "@lightColor" + i;
				//平行光源を加算
				fragmentCode.addCode([
					"$brightness.xyz = dp3($normal.xyz, " + lightAxis + ".xyz)",//ライトの向きとのドット積
					
					//ハーフランバート
					"$brightness.xyz *= @0.5",
					"$brightness.xyz += @0.5",
					"$brightness.xyz *= $brightness.xyz",
					
					"$brightness.xyz = sat($brightness.xyz)",//0～1にする
					"$brightness.xyz *= " + lightColor + ".xyz",//明るさに平行光源カラーを乗算
					"$brightness.xyz *= " + lightColor + ".www",//明るさに平行光源強度を乗算
					"$brightness.xyz *= $common." + xyz,//明るさに影の強度を乗算
					"$total.xyz += $brightness.xyz"
				]);
			}
			
			fragmentCode.addCode([
				"$output.xyz *= $total.xyz"
			]);
		}
		
		private function updateVertexShader():void 
		{
			vertexConstants.number = true;
			vertexConstants.ambient = true;
			vertexConstants.lights = true;
				
			vertexCode.addCode([
				"var $total",
				"var $brightness",
				
				//環境光を加算
				"$total.xyz = @ambientColor.xyz",
				"$total.xyz *= @ambientColor.www"
			]);
			
			for (var i:int = 0; i < LightSetting.numDirectionalLights; i++) 
			{
				var lightAxis:String = "@lightAxis" + i;
				var lightColor:String = "@lightColor" + i;
				//平行光源を加算
				vertexCode.addCode([
					"$brightness.xyz = dp3($normal.xyz, " + lightAxis + ".xyz)",//ライトの向きとのドット積
					
					//ハーフランバート
					"$brightness.xyz *= @0.5",
					"$brightness.xyz += @0.5",
					"$brightness.xyz *= $brightness.xyz",
					
					"$brightness.xyz = sat($brightness.xyz)",//0～1にする
					"$brightness.xyz *= " + lightColor + ".xyz",//明るさに平行光源カラーを乗算
					"$brightness.xyz *= " + lightColor + ".www",//明るさに平行光源強度を乗算
					"$total.xyz += $brightness.xyz"
				]);
			}
			
			vertexCode.addCode([
				"#light = $total.xyz"
			]);
			
			fragmentCode.addCode([
				//光源量を乗算
				"$output.xyz *= #light.xyz"
			]);
		}
		
		override public function clone():MaterialShader 
		{
			return new HalfLambertShader();
		}
		
	}

}