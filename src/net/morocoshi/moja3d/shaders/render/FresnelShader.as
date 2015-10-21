package net.morocoshi.moja3d.shaders.render 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.renderer.RenderLayer;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * フレネル反射シェーダー。反射系シェーダーにフレネル効果を持たせる為の事前計算をする。
	 * 
	 * @author ...
	 */
	public class FresnelShader extends MaterialShader 
	{
		private var _refractRatio:Number;
		private var _incrementRatio:Number;
		private var paramConst:AGALConstant;
		
		/**
		 * コンストラクタ
		 * 
		 * @param	refractRatio	フレネル比。水は1/1.4くらい
		 * @param	incrementRatio	0.4くらいだとちょうどいい
		 */
		public function FresnelShader(refractRatio:Number, incrementRatio:Number) 
		{
			super();
			
			requiredAttribute.push(VertexAttribute.NORMAL);
			
			_refractRatio = refractRatio;
			_incrementRatio = incrementRatio;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "FresnelShader:";
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
			paramConst = fragmentCode.addConstantsFromArray("@fres", [0, 0, 0, 0]);
			calcConst();
		}
		
		private function calcConst():void 
		{
			paramConst.x = _refractRatio;
			paramConst.y = _refractRatio * _refractRatio;
			paramConst.z = _incrementRatio;
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			fragmentConstants.cameraPosition = true;
			fragmentConstants.number = true;
			fragmentCode.addCode(
				//テクセルから視線へのベクトル（正規化）
				"var $eye",
				"$eye.xyz = @cameraPosition.xyz - #wpos.xyz",
				"$eye.xyz = nrm($eye.xyz)",
				//
				"var $b",
				//B
				"$b.x = dp3($eye.xyz, $normal.xyz)",
				//B*B
				"$b.y = $b.x * $b.x",
				//1-BB
				"$b.y = @1 - $b.y",
				//AA(1-BB)
				"$b.y *= @fres.y",
				"$b.y = @1 - $b.y",
				//C
				"$b.y = sqt($b.y)",
				
				//AB
				"$b.z = @fres.x * $b.x",
				//AC
				"$b.w = @fres.x * $b.y",
				
				"var $temp",
				//AB - C, AC - B
				"$temp.xy = $b.zw - $b.yx",
				//AB + C, AC + B
				"$temp.zw = $b.zw + $b.yx",
				
				"$temp.xy /= $temp.zw",
				"$temp.xy *= $temp.xy",
				"$temp.x += $temp.y",
				"$temp.x *= @0.5",
				
				"global $common",
				"$common.w = $temp.x + @fres.z",//フレネル率にincrementRatioを加算
				"$common.w = sat($common.w)"//0～1に収める
			);
		}
		
		override public function clone():MaterialShader 
		{
			return new FresnelShader(_refractRatio, _incrementRatio);
		}
		
	}

}