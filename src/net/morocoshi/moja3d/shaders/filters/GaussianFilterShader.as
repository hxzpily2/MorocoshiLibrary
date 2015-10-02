package net.morocoshi.moja3d.shaders.filters 
{
	import net.morocoshi.moja3d.agal.AGALCode;
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.materials.Mipmap;
	import net.morocoshi.moja3d.materials.Smoothing;
	import net.morocoshi.moja3d.materials.Tiling;
	import net.morocoshi.moja3d.renderer.RenderLayer;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class GaussianFilterShader extends MaterialShader 
	{
		private var _horizontal:Boolean;
		private var _scale:Number;
		private var _segments:int;
		private var _dispersion:Number;
		
		private var weightConstant:Vector.<String>;
		private var offsetConstant:Vector.<String>;
		private var scaleConst:AGALConstant;
		
		public function GaussianFilterShader(horizontal:Boolean, scale:Number, segments:int, dispersion:Number = 50)
		{
			super();
			
			_scale = scale;
			_dispersion = dispersion;
			_segments = segments;
			_horizontal = horizontal;
			
			weightConstant = new Vector.<String>;
			offsetConstant = new Vector.<String>;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "GaussianFilterShader:" + _segments + "_" + horizontal;
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
			
			var weightList:Vector.<Number> = new Vector.<Number>;
			var offsetList:Vector.<int> = new Vector.<int>;
			weightConstant.length = 0;
			offsetConstant.length = 0;
			
			var i:int;
			var total:Number = 0;
			for (i = 0; i < _segments; i++)
			{
				offsetList[i] = i;
				weightList[i] = Math.exp( -0.5 * i * i / _dispersion);
				var m:int = (i == 0)? 1 : 2;
				total += weightList[i] * m;
			}
			
			for (i = 0; i < _segments; i++ )
			{
				weightList[i] /= total;
			}
			
			for (i = 0; i < _segments; i+=4 )
			{
				var wx:Number = weightList[i];
				var wy:Number = (i + 1 < _segments)? weightList[i + 1] : 0;
				var wz:Number = (i + 2 < _segments)? weightList[i + 2] : 0;
				var ww:Number = (i + 3 < _segments)? weightList[i + 3] : 0;
				
				var ox:Number = offsetList[i];
				var oy:Number = (i + 1 < _segments)? offsetList[i + 1] : 0;
				var oz:Number = (i + 2 < _segments)? offsetList[i + 2] : 0;
				var ow:Number = (i + 3 < _segments)? offsetList[i + 3] : 0;
				
				var weightID:String = "@weight" + (i / 4);
				var offsetID:String = "@offset" + (i / 4);
				fragmentCode.addConstantsFromArray(weightID, [wx, wy, wz, ww]);
				fragmentCode.addConstantsFromArray(offsetID, [ox, oy, oz, ow]);
				
				weightConstant.push(weightID + ".x");
				weightConstant.push(weightID + ".y");
				weightConstant.push(weightID + ".z");
				weightConstant.push(weightID + ".w");
				
				offsetConstant.push(offsetID + ".x");
				offsetConstant.push(offsetID + ".y");
				offsetConstant.push(offsetID + ".z");
				offsetConstant.push(offsetID + ".w");
			}
			scaleConst = fragmentCode.addConstantsFromArray("@gaussianScale", [_scale, 0, 0, 0]);
		}
			
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			fragmentConstants.viewSize = true;
			fragmentConstants.number = true;
			
			var tag:String = getTextureTag(Smoothing.LINEAR, Mipmap.NOMIP, Tiling.CLAMP, "");
			fragmentCode.addCode(
				"var $step",
				"var $uvp",
				"var $blur",
				"var $size",
				"$size.xy = @viewSize.xy",
				"$size.xy /= @gaussianScale.xx",
				
				"$uvp.xy = #uv.xy",
				"$output.xyz = @0_0_0"
			)
			
			var xy:String = _horizontal? "x" : "y";
			for (var i:int = -_segments + 1; i <= _segments - 1; i++) 
			{
				var index:int = Math.abs(i);
				if (i == 0)
				{
					fragmentCode.addCode("$size." + xy + " = neg($size." + xy + ")");
				}
				fragmentCode.addCode(
					"$step.x = " + offsetConstant[index] + " / $size." + xy,
					"$uvp." + xy + " = #uv." + xy + " + $step.x",
					"$blur = tex($uvp.xy, fs0, " + tag + ")",
					"$blur *= " + weightConstant[index],
					"$output.xyz += $blur.xyz"
				);
			}
		}
		
		override public function clone():MaterialShader 
		{
			var shader:GaussianFilterShader = new GaussianFilterShader(_horizontal, _scale, _segments, _dispersion);
			return shader;
		}
		
		public function get scale():Number 
		{
			return _scale;
		}
		
		public function set scale(value:Number):void 
		{
			if (_scale == value) return;
			
			_scale = value;
			scaleConst.x = _scale;
		}
		
		public function get dispersion():Number 
		{
			return _dispersion;
		}
		
		public function set dispersion(value:Number):void 
		{
			if (_dispersion == value) return;
			
			_dispersion = value;
			updateConstants();
		}
		
		public function get segments():int 
		{
			return _segments;
		}
		
		public function set segments(value:int):void 
		{
			if (_segments == value) return;
			
			_segments = value;
			updateConstants();
			updateShaderCode();
		}
		
		public function get horizontal():Boolean 
		{
			return _horizontal;
		}
		
		public function set horizontal(value:Boolean):void 
		{
			if (_horizontal == value) return;
			
			_horizontal = value;
			updateShaderCode();
		}
		
	}

}