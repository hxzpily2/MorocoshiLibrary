package net.morocoshi.moja3d.shaders.render 
{
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.agal.AGALTexture;
	import net.morocoshi.moja3d.materials.Mipmap;
	import net.morocoshi.moja3d.materials.Smoothing;
	import net.morocoshi.moja3d.materials.Tiling;
	import net.morocoshi.moja3d.resources.TextureResource;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	use namespace moja3d;
	
	/**
	 * 簡易水面法線マップアニメーション
	 * 
	 * @author tencho
	 */
	public class WaterNormalShader extends MaterialShader 
	{
		private var _ratio:Number;
		private var constant:AGALConstant;
		private var texture:AGALTexture;
		
		public function WaterNormalShader(resource:TextureResource, ratio:Number) 
		{
			super();
			
			tickEnabled = true;
			_ratio = ratio;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
			
			this.resource = resource;
		}
		
		override public function tick(time:int):void
		{
			var t:Number = time / 10000;
			constant.y = t * 0.7;
			constant.z = t * 0.2;
		}
		
		override public function getKey():String 
		{
			return "NormalMapShader:";
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaMode = AlphaMode.UNKNOWN;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
			texture = fragmentCode.addTexture("&waterNormalMap", null, this);
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
			constant = fragmentCode.addConstantsFromArray("@waterNormalRatio", [_ratio, 0, 0, 0]);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			var tag:String = getTextureTag(Smoothing.LINEAR, Mipmap.NOMIP, Tiling.WRAP, texture.getSamplingOption());			
			fragmentConstants.number = true;
			fragmentCode.addCode([
				"var $tangent4",
				"$tangent4.xyz = nrm(#tangent4.xyz)",
				
				"var $uv2",
				"var $image",
				"var $temp",
				
				"$uv2 = @0",
				"$uv2.xy = #uv.xy + @waterNormalRatio.zy",
				"$image.xyz = tex($uv2, &waterNormalMap " + tag + ")",
				"$image.xyz *= @0.5_0.5_0.5",
				
				"$uv2.xy = #uv.xy - @waterNormalRatio.yz",
				"$temp.xyz = tex($uv2, &waterNormalMap " + tag + ")",
				"$temp.xyz *= @0.5_0.5_0.5",
				"$image.xyz += $temp.xyz",
				
				"$image.xyz -= @0.5_0.5_0.5",
				"$image.xyz *= @2_2_2",
				"$image.xy *= @waterNormalRatio.xx",
				
				"var $binormal",
				"$binormal.xyz = crs($normal.xyz, $tangent4.xyz)",
				"$binormal.xyz = nrm($binormal.xyz)",
				
				"$temp.x = sge(#tangent4.w, @0)",
				"$temp.x *= @2",
				"$temp.x -= @1",
				"$binormal.xyz *= $temp.xxx",
				
				"$tangent4.xyz *= $image.xxx",
				"$binormal.xyz *= $image.yyy",
				"$normal.xyz *= $image.zzz",
				
				"$normal.xyz += $binormal.xyz",
				"$normal.xyz += $tangent4.xyz",
				"$normal.xyz = nrm($normal.xyz)"
			]);
		}
		
		public function get resource():TextureResource 
		{
			return texture.texture;
		}
		
		public function set resource(value:TextureResource):void 
		{
			texture.texture = value;
		}
		
		public function get ratio():Number 
		{
			return _ratio;
		}
		
		public function set ratio(value:Number):void 
		{
			constant.x = _ratio = value;
		}
		
		override public function reference():MaterialShader 
		{
			return new WaterNormalShader(resource, _ratio);
		}
		
		override public function clone():MaterialShader 
		{
			return new WaterNormalShader(cloneTexture(resource), _ratio);
		}
	}

}