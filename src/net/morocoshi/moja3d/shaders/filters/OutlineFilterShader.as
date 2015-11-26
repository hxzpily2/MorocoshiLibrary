package net.morocoshi.moja3d.shaders.filters 
{
	import net.morocoshi.moja3d.materials.Mipmap;
	import net.morocoshi.moja3d.materials.Smoothing;
	import net.morocoshi.moja3d.materials.Tiling;
	import net.morocoshi.moja3d.renderer.MaskColor;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * マスク画像を元に境界線を描く
	 * 
	 * @author tencho
	 */
	public class OutlineFilterShader extends MaterialShader 
	{
		private var elements:Vector.<OutlineFilterElement>;
		
		public function OutlineFilterShader()
		{
			super();
			elements = new Vector.<OutlineFilterElement>;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		public function addElement(mask:uint, color:uint, alpha:Number):void
		{
			elements.push(new OutlineFilterElement(mask, color, alpha));
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			var key:String = "";
			var n:int = elements.length;
			for (var i:int = 0; i < n; i++) 
			{
				key += elements[i].getKey() + "_";
			}
			return "OutlineFilterShader:" + key;
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
			fragmentCode.addConstantsFromArray("@outline1", [ -1, 0, 1, 0]);
			fragmentCode.addConstantsFromArray("@outline2", [ -2, 2, 0, 0]);
			
			var n:int = elements.length;
			for (var i:int = 0; i < n; i++) 
			{
				elements[i].id = "@outlineColor" + i;
				elements[i].constant = fragmentCode.addConstantsFromColor(elements[i].id, elements[i].color, elements[i].alpha);
			}
			
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			var tag:String = getTextureTag(Smoothing.LINEAR, Mipmap.NOMIP, Tiling.CLAMP, "");
			fragmentConstants.viewSize = true;
			fragmentCode.addCode([
				"var $per",
				"var $uvp",
				"var $image",
				//元画像
				"$output.xyz = tex(#uv.xy, fs0, " + tag + ")"
			]);
			
			var n:int = elements.length;
			for (var i:int = 0; i < n; i++) 
			{
				var element:OutlineFilterElement = elements[i];
				
				var xyz:String;
				switch(element.mask)
				{
					case MaskColor.RED: xyz = "x"; break;
					case MaskColor.GREEN: xyz = "y"; break;
					case MaskColor.BLUE: xyz = "z"; break;
					default: xyz = "x";
				}
				
				fragmentCode.addCode([
					"$image.w = @outline1.y"//0にリセットしておく
					
				]);
				var xy:Array = ["@outline2.x", "@outline1.x", "@outline1.y", "@outline1.z", "@outline2.y"];
				for (var ix:int = 1; ix < xy.length - 1; ix++) 
				for (var iy:int = 1; iy < xy.length - 1; iy++) 
				{
					if (ix == 0 && iy == 0) continue;
					
					fragmentCode.addCode([
						"$uvp.x = " + xy[ix],
						"$uvp.y = " + xy[iy],
						"$uvp.xy /= @viewSize.xy",
						"$uvp.xy += #uv.xy",
						//マスク画像
						"$image.xyz = tex($uvp.xy, fs1, " + tag + ")",
						"$image.w += $image." + xyz
					]);
				}
				fragmentCode.addCode([
					"$image.w = sat($image.w)",//0-1
					//マスク画像でくりぬき
					"$image.xyz = tex(#uv, fs1, " + tag + ")",
					"$image.w -= $image." + xyz,//境界線の描画判定0-1
					
					"$image.xyz = " + element.id + ".xyz",//境界線色
					"$per.x = $image.w * " + element.id + ".w",//境界線アルファ
					
					//output * (1 - per) + image * (per);
					"$per.y = @outline1.z - $image.w",
					"$output.xyz *= $per.y",
					"$image.xyz *= $per.x",
					"$output.xyz += $image.xyz"
				]);
			}
		}
		
		override public function clone():MaterialShader 
		{
			var shader:OutlineFilterShader = new OutlineFilterShader();
			shader.elements = elements.concat();
			return shader;
		}
		
	}

}