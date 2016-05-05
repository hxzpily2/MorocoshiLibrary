package net.morocoshi.moja3d.shaders.outline 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.shaders.AlphaTransform;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * アウトラインシェーダー
	 * 
	 * @author tencho
	 */
	public class OutlineColorShader extends MaterialShader 
	{
		private var _fixed:Boolean;
		private var vertexConst:AGALConstant;
		private var fragmentConst:AGALConstant;
		private var _thickness:Number;
		private var _color:uint;
		private var _alpha:Number;
		
		public function OutlineColorShader(thickness:Number = 1, color:uint = 0x000000, alpha:Number = 1, fixed:Boolean = true) 
		{
			super();
			
			_thickness = thickness;
			_color = color;
			_alpha = alpha;
			_fixed = fixed;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "OutlineColorShader:" + alphaTransform + "_" + int(_fixed);
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaTransform = (_alpha < 1)? AlphaTransform.SET_TRANSPARENT : AlphaTransform.SET_OPAQUE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
			vertexConst =　vertexCode.addConstantsFromArray("@outlineSize", [1, 0, 0, 0]);
			fragmentConst = fragmentCode.addConstantsFromColor("@outlineColor", _color, _alpha);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			vertexConstants.projMatrix = true;
			vertexConstants.clipMatrix = true;
			vertexConstants.cameraPosition = true;
			
			vertexCode.addCode([
				"$normal.xyz = nrm($normal.xyz)",
				"var $normal2",
				"$normal2.xyz = $normal.xyz",
				"$normal2.xyz = m33($normal2.xyz, @viewMatrix)",//ビュー行列で変換
			]);
			
			if (_fixed)
			{
				vertexCode.addCode([
					"$normal2.xyz = m33($normal2.xyz, @projMatrix)"//プロジェクション行列?で変換
				]);
			}
			else
			{
				vertexCode.addCode([
					"$normal2.xyz *= @outlineSize.xxx",
					"$pos.xyz += $normal2.xyz"
				]);
			}
			
			vertexCode.addCode([
				"#vpos = $pos",
				"$pos = m44($pos, @projMatrix)"//プロジェクション行列?で変換
			]);
			
			if (_fixed)
			{
				vertexCode.addCode([
					"$normal2.xy *= $pos.zz",
					"$normal2.xy /= @cameraPosition.ww",
					"$normal2.xy *= @outlineSize.xx",
					"$pos.xy += $normal2.xy"
				]);
			}
			
			vertexCode.addCode([
				"#spos = $pos",//スクリーン座標
				"$pos = m44($pos, @clipMatrix)",//クリッピング行列?で変換
				"op = $pos.xyzw",
				
				//ワールド法線
				"#normal = $normal.xyz"
			]);
			
			fragmentCode.addCode([
				"$output = @outlineColor"
			]);
		}
		
		override public function clone():MaterialShader 
		{
			return new OutlineColorShader(_thickness, _color, _alpha, _fixed);
		}
		
		public function get thickness():Number 
		{
			return _thickness;
		}
		
		public function set thickness(value:Number):void 
		{
			vertexConst.x = _thickness = value;
		}
		
		public function get color():uint 
		{
			return _color;
		}
		
		public function set color(value:uint):void 
		{
			fragmentConst.setRGB(_color = value);
		}
		
		public function get alpha():Number 
		{
			return _alpha;
		}
		
		public function set alpha(value:Number):void 
		{
			fragmentConst.w = (_alpha = value);
			updateAlphaMode();
		}
		
		public function get fixed():Boolean 
		{
			return _fixed;
		}
		
		public function set fixed(value:Boolean):void 
		{
			_fixed = value;
			updateShaderCode();
		}
		
	}

}