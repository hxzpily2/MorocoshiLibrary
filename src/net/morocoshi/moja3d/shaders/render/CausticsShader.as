package net.morocoshi.moja3d.shaders.render 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.agal.AGALTexture;
	import net.morocoshi.moja3d.materials.Mipmap;
	import net.morocoshi.moja3d.materials.Smoothing;
	import net.morocoshi.moja3d.materials.Tiling;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.resources.TextureResource;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	use namespace moja3d;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class CausticsShader extends MaterialShader 
	{
		private var _texture:TextureResource;
		private var animationConst:AGALConstant;
		private var _segmentW:int;
		private var _segmentH:int;
		private var _numImages:int;
		private var _width:Number;
		private var _height:Number;
		private var _alpha:Number;
		private var _top:Number;
		private var _topGradation:Number;
		private var _bottom:Number;
		private var _bottomGradation:Number;
		private var patternTexture:AGALTexture;
		
		public function CausticsShader(texture:TextureResource, alpha:Number, width:Number, height:Number, segmentW:int, segmentH:int, numImages:int) 
		{
			super();
			
			tickEnabled = true;
			_alpha = alpha;
			_width = width;
			_height = height;
			_segmentW = segmentW;
			_segmentH = segmentH;
			_numImages = numImages;
			_texture = texture;
			_top = 0;
			_topGradation = 10;
			_bottom = -100;
			_bottomGradation = 10;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		public function setExtentRange(top:Number, topGradation:Number, bottom:Number, bottomGradation:Number):void
		{
			_top = top;
			_topGradation = topGradation;
			_bottom = bottom;
			_bottomGradation = bottomGradation;
			updateConstants();
		}
		
		override public function tick(time:int):void 
		{
			var paddingW:Number = 0;// _texture.texture.data.width;
			var paddingH:Number = 0;// _texture.data.height;
			var frame:int = int(time / 100) % _numImages;
			var width:Number = 1 / _segmentW;
			var height:Number = 1 / _segmentH;
			animationConst.z = width - paddingW * 2;
			animationConst.w = height - paddingH * 2;
			animationConst.x = width * int(frame % _segmentW) + paddingW;
			animationConst.y = height * int(frame / _segmentH) + paddingH;
		}
		
		override public function getKey():String 
		{
			return "CausticsShader:" + getSamplingKey(patternTexture);
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaMode = AlphaMode.NONE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
			patternTexture = fragmentCode.addTexture("&causticsMap", _texture, this);
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
			animationConst = fragmentCode.addConstantsFromArray("@anm", null);
			fragmentCode.addConstantsFromArray("@size", [_width, _height, _alpha, 0]);
			//top, topFade(>0), bottom, bottomFase(>0)
			fragmentCode.addConstantsFromArray("@fade", [_top, _topGradation, _bottom, _bottomGradation]);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			var tag:String = getTextureTag(Smoothing.LINEAR, Mipmap.MIPLINEAR, Tiling.WRAP, patternTexture.getSamplingOption());
			fragmentConstants.number = true;
			fragmentCode.addCode([
				"var $image",
				"var $uvw",
				"$uvw.xy = #wpos.xy / @size.xy",
				"$uvw.xy = frc($uvw.xy)",
				"$uvw.xy *= @anm.zw",
				"$uvw.xy += @anm.xy",
				"$image = tex($uvw.xy, &causticsMap " + tag + ")",
				
				"$uvw.x = @fade.x - #wpos.z",
				"$uvw.y = #wpos.z - @fade.z",
				"$uvw.xy /= @fade.yw",
				//"$uvw.y /= @fade.w",
				
				"$uvw.xy = sat($uvw.xy)",
				"$uvw.x *= $uvw.y",
				
				"$image.xyz *= $uvw.xxx",
				"$image.xyz *= @size.zzz",
				"$output.xyz += $image.xyz"
			]);
		}
		
		override public function reference():MaterialShader 
		{
			return new CausticsShader(_texture, _alpha, _width, _height, _segmentW, _segmentH, _numImages);
		}
		
		override public function clone():MaterialShader 
		{
			return new CausticsShader(cloneTexture(_texture), _alpha, _width, _height, _segmentW, _segmentH, _numImages);
		}
		
	}

} 