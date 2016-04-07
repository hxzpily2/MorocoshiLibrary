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
		private var vertexConst:AGALConstant;
		private var fragmentConst:AGALConstant;
		private var _thickness:Number;
		private var _color:uint;
		private var _alpha:Number;
		
		public function OutlineColorShader(thickness:Number = 1, color:uint = 0x000000, alpha:Number = 1) 
		{
			super();
			
			_thickness = thickness;
			_color = color;
			_alpha = alpha;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "OutlineColorShader:" + alphaTransform;
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
			fragmentConst =fragmentCode.addConstantsFromColor("@outlineColor", _color, _alpha);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			vertexConstants.projMatrix = true;
			vertexConstants.clipMatrix = true;
			vertexConstants.cameraPosition = true;
			
			vertexCode.addCode([
				"var $normal2",
				"$normal.xyz = nrm($normal.xyz)",
				"$normal2.xyz = $normal.xyz",
				"$normal2.xyz = m33($normal2, @viewMatrix)",//ビュー行列で変換
				"$normal2.xyz = m33($normal2, @projMatrix)",//プロジェクション行列?で変換
				//"$normal2.xyz = nrm($normal2.xyz)",
				//"$normal2.xy /= @viewSize.xy",
				
				"#vpos = $pos",
				"$pos = m44($pos, @projMatrix)",//プロジェクション行列?で変換
				
				"$normal2.xy *= $pos.zz",
				"$normal2.xy /= @cameraPosition.ww",
				"$normal2.xy *= @outlineSize.xx",
				"$pos.xy += $normal2.xy",
				
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
			return new OutlineColorShader(_thickness, _color, _alpha);
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
		
	}

}