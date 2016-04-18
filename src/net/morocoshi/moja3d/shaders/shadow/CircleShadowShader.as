package net.morocoshi.moja3d.shaders.shadow
{
	import flash.utils.Dictionary;
	import net.morocoshi.common.math.list.VectorUtil;
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.agal.AGALTexture;
	import net.morocoshi.moja3d.materials.Mipmap;
	import net.morocoshi.moja3d.materials.Smoothing;
	import net.morocoshi.moja3d.materials.Tiling;
	import net.morocoshi.moja3d.objects.Object3D;
	import net.morocoshi.moja3d.resources.TextureResource;
	import net.morocoshi.moja3d.shaders.AlphaTransform;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * 丸影テクスチャをオブジェクトの真下に落とすシェーダー
	 * 
	 * @author tencho
	 */
	public class CircleShadowShader extends MaterialShader 
	{
		private var shadowUnitList:Vector.<CircleShadowUnit>;
		private var texture:AGALTexture;
		private var _width:Number;
		private var _height:Number;
		private var sizeConst:AGALConstant;
		private var positionConstLink:Dictionary;
		private var dataConstLink:Dictionary;
		private var dataLink:Dictionary;
		
		public function CircleShadowShader(resource:TextureResource, width:Number, height:Number) 
		{
			super();
			
			_width = width;
			_height = height;
			shadowUnitList = new Vector.<CircleShadowUnit>;
			positionConstLink = new Dictionary();
			dataConstLink = new Dictionary();
			dataLink = new Dictionary();
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
			
			this.resource = resource;
		}
		
		public function addCastObject(object:Object3D, height:Number, alpha:Number = 1, offset:Number = 0, scale:Number = 1):CircleShadowUnit
		{
			for each (var item:CircleShadowUnit in shadowUnitList) 
			{
				if (item.object == object)
				{
					return item;
				}
			}
			
			var unit:CircleShadowUnit = new CircleShadowUnit();
			unit.object = object;
			unit.offset = offset;
			unit.height = height;
			unit.alpha = alpha;
			unit.scale = scale;
			VectorUtil.attachItemDiff(shadowUnitList, unit);
			
			updateConstants();
			updateShaderCode();
			
			return unit;
		}
		
		public function removeCastObject(object:Object3D):void
		{
			for each (var item:CircleShadowUnit in shadowUnitList) 
			{
				if (item.object == object)
				{
					VectorUtil.deleteItem(shadowUnitList, item);
					break;
				}
			}
			
			updateConstants();
			updateShaderCode();
		}
		
		public function update():void
		{
			var n:int = shadowUnitList.length;
			for (var i:int = 0; i < n; i++) 
			{
				shadowUnitList[i].update();
			}
		}
		
		override public function getKey():String 
		{
			return "CircleShadowShader:" + getSamplingKey(texture);
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaTransform = AlphaTransform.UNCHANGE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
			texture = fragmentCode.addTexture("&circleShadow", null, this);
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
			sizeConst = fragmentCode.addConstantsFromArray("@circleSize", [_width, _height, _width / 2, _height / 2]);
			
			var n:int = shadowUnitList.length;
			for (var i:int = 0; i < n; i++) 
			{
				var unit:CircleShadowUnit = shadowUnitList[i];
				unit.positionConst = fragmentCode.addConstantsFromArray("@unitPosition" + i, [0, 0, 0, 0]);
				unit.dataConst = fragmentCode.addConstantsFromArray("@unitData" + i, [0, 0, 0, 0]);
			}
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			fragmentConstants.number = true;
			fragmentCode.addCode([
				"var $temp",
				"var $size"
			]);
			var tag:String = texture.getOption2D(Smoothing.LINEAR, Mipmap.MIPLINEAR, Tiling.CLAMP);
			var n:int = shadowUnitList.length;
			for (var i:int = 0; i < n; i++) 
			{
				var va1:String = "@unitPosition" + i;
				var va2:String = "@unitData" + i;
				fragmentCode.addCode([
					"$temp.xyw = " + va1 + ".xyz - #wpos.xyz",
					"$size.xyzw = @circleSize.xyzw",
					"$size *= " + va2 + ".w",
					"$temp.xy += $size.zw",
					"$temp.xy /= $size.xy",
					"$temp.w +=" + va2 + ".x",
					"$temp.w /=" + va2 + ".y",
					"$temp.z = slt(@0, $temp.w)",
					
					"$temp.w = @1 - $temp.w",
					"$temp.w = sat($temp.w)",
					"$temp.w *= " + va2 + ".z",
					"$temp.w *= $temp.z",
					
					"$temp.x = tex($temp.xy, &circleShadow " + tag + ")",
					"$temp.x *= $temp.w",
					"$temp.x = @1 - $temp.x",
					"$output.xyz *= $temp.xxx"
				]);
			}
		}
		
		override public function reference():MaterialShader 
		{
			return new CircleShadowShader(resource, _width, _height);
		}
		
		override public function clone():MaterialShader 
		{
			return new CircleShadowShader(cloneTexture(resource), _width, _height);
		}
		
		public function get resource():TextureResource 
		{
			return texture.texture;
		}
		
		public function set resource(value:TextureResource):void 
		{
			texture.texture = value;
		}
		
		public function get width():Number 
		{
			return _width;
		}
		
		public function set width(value:Number):void 
		{
			sizeConst.x = _width = value;
			sizeConst.z = _width / 2;
		}
		
		public function get height():Number 
		{
			return _height;
		}
		
		public function set height(value:Number):void 
		{
			sizeConst.y = _height = value;
			sizeConst.w = _height / 2;
		}
		
	}

}