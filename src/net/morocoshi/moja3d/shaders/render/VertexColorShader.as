package net.morocoshi.moja3d.shaders.render 
{
	import flash.display.BlendMode;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.AlphaTransform;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * 頂点カラー
	 * 
	 * @author tencho
	 */
	public class VertexColorShader extends MaterialShader 
	{
		private var _colorBlend:String;
		private var _alphaBlend:String;
		
		/**
		 * 
		 * @param	colorBlend
		 * @param	alphaBlend
		 */
		public function VertexColorShader(colorBlend:String = BlendMode.MULTIPLY, alphaBlend:String = BlendMode.MULTIPLY) 
		{
			super();
			
			requiredAttribute.push(VertexAttribute.VERTEXCOLOR);
			
			_colorBlend = colorBlend;
			_alphaBlend = alphaBlend;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "VertexColorShader:" + _colorBlend + "_" + _alphaBlend;
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaTransform = (_alphaBlend == "")? AlphaTransform.UNCHANGE : AlphaTransform.SET_MIXTURE;
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
			
			if (_colorBlend == _alphaBlend)
			{
				switch(_colorBlend)
				{
					case "": break;
					case BlendMode.ADD:			fragmentCode.addCode(["$output.xyzw += #vcolor.xyzw"]); break;
					case BlendMode.SUBTRACT:	fragmentCode.addCode(["$output.xyzw -= #vcolor.xyzw"]); break;
					case BlendMode.MULTIPLY:	fragmentCode.addCode(["$output.xyzw *= #vcolor.xyzw"]); break;
					case BlendMode.NORMAL:		fragmentCode.addCode(["$output.xyzw = #vcolor.xyzw"]); break;
					default:					fragmentCode.addCode(["$output.xyzw = #vcolor.xyzw"]);
				}
				return;
			}
			
			switch(_colorBlend)
			{
				case "": break;
				case BlendMode.ADD:			fragmentCode.addCode(["$output.xyz += #vcolor.xyz"]); break;
				case BlendMode.SUBTRACT:	fragmentCode.addCode(["$output.xyz -= #vcolor.xyz"]); break;
				case BlendMode.MULTIPLY:	fragmentCode.addCode(["$output.xyz *= #vcolor.xyz"]); break;
				case BlendMode.NORMAL:		fragmentCode.addCode(["$output.xyz = #vcolor.xyz"]); break;
				default:					fragmentCode.addCode(["$output.xyz = #vcolor.xyz"]);
			}
			switch(_alphaBlend)
			{
				case "": break;
				case BlendMode.ADD:			fragmentCode.addCode(["$output.w += #vcolor.w"]); break;
				case BlendMode.SUBTRACT:	fragmentCode.addCode(["$output.w -= #vcolor.w"]); break;
				case BlendMode.MULTIPLY:	fragmentCode.addCode(["$output.w *= #vcolor.w"]); break;
				case BlendMode.NORMAL:		fragmentCode.addCode(["$output.w = #vcolor.w"]); break;
				default:					fragmentCode.addCode(["$output.w = #vcolor.w"]);
			}
		}
		
		override public function clone():MaterialShader 
		{
			return new VertexColorShader(_colorBlend, _alphaBlend);
		}
		
		public function get colorBlend():String 
		{
			return _colorBlend;
		}
		
		public function set colorBlend(value:String):void 
		{
			_colorBlend = value;
			updateShaderCode();
			updateAlphaMode();
		}
		
		public function get alphaBlend():String 
		{
			return _alphaBlend;
		}
		
		public function set alphaBlend(value:String):void 
		{
			_alphaBlend = value;
			updateShaderCode();
			updateAlphaMode();
		}
		
	}

}