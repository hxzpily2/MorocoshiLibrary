package net.morocoshi.moja3d.shaders.filters 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.agal.AGALTexture;
	import net.morocoshi.moja3d.materials.Mipmap;
	import net.morocoshi.moja3d.materials.Smoothing;
	import net.morocoshi.moja3d.materials.Tiling;
	import net.morocoshi.moja3d.resources.TextureResource;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class AuraFilterShader extends MaterialShader
	{
		private var _scrollU:Number;
		private var _scrollV:Number;
		private var _density:Number;
		private var _noiseX:Number;
		private var _noiseY:Number;
		private var _intensity:Number;
		private var _noiseScale:Number;
		private var _noiseTexture:TextureResource;
		
		private var noiseTextureAGAL:AGALTexture;
		private var alphaConst:AGALConstant;
		private var noiseConst:AGALConstant;
		
		public function AuraFilterShader(density:Number, intensity:Number, noiseTexture:TextureResource, noiseX:Number = 0, noiseY:Number = 0, noiseScale:Number = 1) 
		{
			super();
			
			_scrollU = 0;
			_scrollV = 0;
			_density = density;
			_intensity = intensity;
			
			_noiseTexture = noiseTexture;
			_noiseX = noiseX;
			_noiseY = noiseY;
			_noiseScale = noiseScale;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "AuraFilterShader:";
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaMode = AlphaMode.NONE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
			noiseTextureAGAL = fragmentCode.addTexture("&noise", _noiseTexture, this);
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
			alphaConst = fragmentCode.addConstantsFromArray("@aura", [_density, _noiseX, _noiseY, 0]);
			noiseConst = fragmentCode.addConstantsFromArray("@noise", [_noiseScale, _intensity, _scrollU, -_scrollV]);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			var tag1:String = getTextureTag(Smoothing.LINEAR, Mipmap.NOMIP, Tiling.CLAMP, "");
			var tag2:String = getTextureTag(Smoothing.LINEAR, Mipmap.NOMIP, Tiling.WRAP, "");
			var noiseTag:String = getTextureTag(Smoothing.LINEAR, Mipmap.MIPLINEAR, Tiling.CLAMP, noiseTextureAGAL.getSamplingOption());
			
			fragmentConstants.number = true;
			fragmentConstants.viewSize = true;
			fragmentCode.addCode(
				
				"var $glow",
				"var $mask",
				
				"var $noise",
				"var $uv1",
				
				
				"$uv1.xy = #uv.xy",
				"$uv1.xy *= @noise.xx",
				"$uv1.y /= @viewSize.x",
				"$uv1.y *= @viewSize.y",
				"$uv1.xy += @noise.zw",
				"$noise.xyz = tex($uv1.xy, fs3, " + tag2 + ")",
				"$noise.xyz -= @0.5_0.5_0.5",
				"$noise.xy *= @aura.yz",
				
				"var $offset",
				"$offset.xy = #uv.xy",
				"$offset.xy += $noise.xy",
				
				"$glow = tex($offset.xy, fs1 " + tag1 + ")",
				
				"$mask = tex(#uv.xy, fs2 " + tag1 + ")",
				"$mask.x = max($mask.x, $mask.y)",
				"$mask.x = max($mask.x, $mask.z)",
				"$glow.xyz -= $mask.xxx",
				"$glow = sat($glow)",
				"$glow.xyz *= @aura.xxx",
				
				"$mask.x = max($glow.x, $glow.y)",
				"$mask.x = max($mask.x, $glow.z)",
				"$mask.x *= @noise.y",
				"$mask.x += @1",
				//"$glow.xyz *= @aura.xxx",
				"$output.xyz = tex(#uv.xy, fs0 " + tag1 + ")",
				"$output.xyz += $glow.xyz",
				"$output.xyz *= $mask.xxx"
			);
		}
		
		override public function clone():MaterialShader 
		{
			var shader:AuraFilterShader = new AuraFilterShader(_density, _intensity, _noiseTexture, _noiseX, _noiseY, _noiseScale);
			return shader;
		}
		
		public function get density():Number 
		{
			return _density;
		}
		
		public function set density(value:Number):void 
		{
			alphaConst.x = _density = value;
		}
		
		public function get scrollU():Number 
		{
			return _scrollU;
		}
		
		public function set scrollU(value:Number):void 
		{
			noiseConst.z = _scrollU = value;
		}
		
		public function get scrollV():Number 
		{
			return _scrollV;
		}
		
		public function set scrollV(value:Number):void 
		{
			noiseConst.w = -(_scrollV = value);
		}
		
	}

}