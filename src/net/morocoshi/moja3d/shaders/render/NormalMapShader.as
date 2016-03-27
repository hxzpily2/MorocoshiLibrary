package net.morocoshi.moja3d.shaders.render 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.agal.AGALTexture;
	import net.morocoshi.moja3d.events.Event3D;
	import net.morocoshi.moja3d.materials.Mipmap;
	import net.morocoshi.moja3d.materials.Smoothing;
	import net.morocoshi.moja3d.materials.Tiling;
	import net.morocoshi.moja3d.resources.TextureResource;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.AlphaTransform;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class NormalMapShader extends MaterialShader 
	{
		private var _resource:TextureResource;
		private var _scale:Number;
		private var texture:AGALTexture;
		private var scaleConst:AGALConstant;
		
		public function NormalMapShader(resource:TextureResource, scale:Number) 
		{
			super();
			
			requiredAttribute.push(VertexAttribute.NORMAL);
			requiredAttribute.push(VertexAttribute.TANGENT4);
			
			_scale = scale;
			this.resource = resource;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "NormalMapShader:" + getSamplingKey(texture);
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaTransform = AlphaTransform.UNCHANGE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
			texture = fragmentCode.addTexture("&normal", _resource, this);
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
			scaleConst = fragmentCode.addConstantsFromArray("@scale", [_scale, 0, 0, 0]);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			fragmentConstants.number = true;
			
			var tag:String = texture.getOption2D(Smoothing.LINEAR, Mipmap.MIPLINEAR, Tiling.WRAP);
			fragmentCode.addCode([
				"var $tangent4",
				"$tangent4.xyz = nrm(#tangent4.xyz)",
				
				"var $image",
				"$image.xyz = tex(#uv, &normal " + tag + ")",
				"$image.xyz -= @0.5_0.5_0.5",
				"$image.xyz *= @2_2_2",
				"$image.xy *= @scale.xx",
				//"$image.xyz = nrm($image.xyz)",
				
				"var $binormal",
				"$binormal.xyz = crs($normal.xyz, $tangent4.xyz)",
				"$binormal.xyz = nrm($binormal.xyz)",
				
				"var $scale",
				"$scale.x = sge(#tangent4.w, @0)",
				"$scale.x *= @2",
				"$scale.x -= @1",
				"$binormal.xyz *= $scale.xxx",
				
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
			return _resource;
		}
		
		public function set resource(value:TextureResource):void 
		{
			//関連付けられていたパースイベントを解除しておく
			if (_resource) _resource.removeEventListener(Event3D.RESOURCE_PARSED, image_parsedHandler);
			
			//テクスチャリソースの差し替え
			_resource = value;
			if (texture) texture.texture = _resource;
			
			//新しいパースイベントを関連付ける
			if (_resource) _resource.addEventListener(Event3D.RESOURCE_PARSED, image_parsedHandler);
			
			updateAlphaMode();
		}
		
		private function image_parsedHandler(e:Event3D):void 
		{
			updateAlphaMode();
		}
		
		public function get scale():Number 
		{
			return _scale;
		}
		
		public function set scale(value:Number):void 
		{
			_scale = value;
			scaleConst.x = _scale;
		}
		
		override public function reference():MaterialShader
		{
			return new NormalMapShader(_resource, _scale);
		}
		
		override public function clone():MaterialShader 
		{
			return new NormalMapShader(cloneTexture(_resource), _scale);
		}
		
	}

}