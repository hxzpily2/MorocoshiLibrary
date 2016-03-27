package net.morocoshi.moja3d.shaders.render 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.renderer.RenderPhase;
	import net.morocoshi.moja3d.shaders.AlphaTransform;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	import net.morocoshi.moja3d.shaders.depth.DepthAlphaShader;
	
	/**
	 * 単色塗シェーダー
	 * 
	 * @author tencho
	 */
	public class FillShader extends MaterialShader 
	{
		private var _color:uint;
		private var _alpha:Number;
		private var colorConstant:AGALConstant;
		private var depthShader:DepthAlphaShader;
		
		public function FillShader(rgb:uint, alpha:Number) 
		{
			super();
			
			_color = rgb;
			_alpha = alpha;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "FillShader:";
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			if (_alpha < 1)
			{
				alphaTransform = AlphaTransform.SET_TRANSPARENT;
			}
			else if (_alpha > 1)
			{
				alphaTransform = AlphaTransform.SET_UNKNOWN;
			}
			else
			{
				alphaTransform = AlphaTransform.SET_OPAQUE;
			}
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
			
			colorConstant = fragmentCode.addConstantsFromColor("@fillColor", _color, _alpha);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			fragmentCode.addCode(["$output.xyzw = @fillColor"]);
		}
		
		public function get color():uint 
		{
			return _color;
		}
		
		public function set color(value:uint):void 
		{
			_color = value;
			colorConstant.setRGB(_color);
		}
		
		public function get alpha():Number 
		{
			return _alpha;
		}
		
		public function set alpha(value:Number):void 
		{
			_alpha = value;
			colorConstant.vector[3] = _alpha;
			if (depthShader)
			{
				depthShader.alpha = _alpha;
			}
			updateAlphaMode();
		}
		
		override public function clone():MaterialShader 
		{
			return new FillShader(_color, _alpha);
		}
		
		override public function getExtraShader(phase:String):MaterialShader 
		{
			if (phase == RenderPhase.DEPTH)
			{
				if (depthShader == null)
				{
					depthShader = new DepthAlphaShader(_alpha);
				}
				return depthShader;
			}
			return null;
		}
		
	}

}