package net.morocoshi.moja3d.shaders.render 
{
	import net.morocoshi.moja3d.config.LightSetting;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ランバートシェーディング（頂点ベースの軽い版）
	 * 
	 * @author tencho
	 */
	public class LambertVertexShader extends MaterialShader 
	{
		public function LambertVertexShader() 
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
			return "LambertVertexShader:";
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
					"$brightness.xyz = sat($brightness.xyz)",//0～1にする
					"$brightness.xyz *= " + lightColor + ".xyz",//明るさに平行光源カラーを乗算
					"$brightness.xyz *= " + lightColor + ".www",//明るさに平行光源強度を乗算
					"$total.xyz += $brightness.xyz"
				]);
			}
			
			vertexCode.addCode(["#light = $total.xyz"]);
			fragmentCode.addCode(["$output.xyz *= #light.xyz"]);//光源量を乗算
		}
		
		override public function clone():MaterialShader 
		{
			return new LambertVertexShader();
		}
		
	}

}