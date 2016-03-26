package net.morocoshi.moja3d.shaders.filters 
{
	import flash.display.BlendMode;
	import net.morocoshi.common.math.list.VectorUtil;
	import net.morocoshi.moja3d.agal.AGALTexture;
	import net.morocoshi.moja3d.materials.Mipmap;
	import net.morocoshi.moja3d.materials.Smoothing;
	import net.morocoshi.moja3d.materials.Tiling;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	use namespace moja3d;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class DrawMaskShader extends MaterialShader 
	{
		private var items:Vector.<MaskItem>;
		private var textureIndex:int;
		private var _blendMode:String;
		
		public function DrawMaskShader(textureIndex:int, blendMode:String = BlendMode.ADD) 
		{
			super();
			
			_blendMode = blendMode;
			this.textureIndex = textureIndex;
			items = new Vector.<MaskItem>;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		public function removeMask(mask:uint):Boolean
		{
			for each (var item:MaskItem in items) 
			{
				if (item.mask == mask)
				{
					VectorUtil.deleteItem(items, item);
					return true;
				}
			}
			return false;
		}
		
		public function addMask(mask:uint, color:uint, density:Number):MaskItem
		{
			var item:MaskItem;
			for each (item in items) 
			{
				if (item.mask == mask)
				{
					item.color = color;
					item.density = density;
					return item;
				}
			}
			
			item = new MaskItem();
			item.color = color;
			item.mask = mask;
			item.density = density;
			items.push(item);
			
			updateConstants();
			updateShaderCode();
			
			return item;
		}
		
		override public function getKey():String 
		{
			return "DrawMaskShader:" + items.length + "_" + _blendMode;
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
			
			var item:MaskItem;
			var n:int = items.length;
			for (var i:int = 0; i < n; i++) 
			{
				item = items[i];
				fragmentCode.addConstantsFromColor("@mask" + i, item.mask, 1);
				item.constant = fragmentCode.addConstantsFromColor("@color" + i, item.color, 1);
				item.updateColor();
			}
			item = null;
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			var tag:String = AGALTexture.getTextureOption2D(Smoothing.LINEAR, Mipmap.NOMIP, Tiling.CLAMP);
			
			fragmentConstants.number = true;
			fragmentCode.addCode([
				"var $rawImage",
				"var $image",
				"$rawImage.xyzw = tex(#uv.xy, fs" + textureIndex + ", " + tag + ")",
				"$output.xyzw = @0_0_0_1"
			]);
			
			var n:int = items.length;
			for (var i:int = 0; i < n; i++) 
			{
				fragmentCode.addCode([
					"$image.xyzw = $rawImage.xyzw",
					"$image.xyz *= @mask" + i + ".xyz",
					"$image.x = max($image.x, $image.y)",
					"$image.x = max($image.x, $image.z)",
					"$image.xyz = @color" + i + ".xyz * $image.xxx"
				]);
				switch(_blendMode)
				{
					case BlendMode.ADD: fragmentCode.addCode(["$output.xyz += $image.xyz"]); break;
					case BlendMode.SUBTRACT: fragmentCode.addCode(["$output.xyz -= $image.xyz"]); break;
				}
			}
		}
		
		override public function clone():MaterialShader 
		{
			var shader:DrawMaskShader = new DrawMaskShader(textureIndex, _blendMode);
			var n:int = items.length;
			for (var i:int = 0; i < n; i++) 
			{
				shader.addMask(items[i].color, items[i].mask, items[i].density);
			}
			return shader;
		}
		
		public function get blendMode():String 
		{
			return _blendMode;
		}
		
		public function set blendMode(value:String):void 
		{
			_blendMode = value;
			updateShaderCode();
		}
		
	}

}