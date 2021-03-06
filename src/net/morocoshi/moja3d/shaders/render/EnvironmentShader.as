package net.morocoshi.moja3d.shaders.render 
{
	import flash.display.BlendMode;
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
	 * 環境マップシェーダー。キューブマップリソースを使用。フレネル反射にも対応。
	 * 
	 * @author tencho
	 */
	public class EnvironmentShader extends MaterialShader 
	{
		//private var _resource:TextureResource;
		private var _reflection:Number;
		private var _blendMode:String;
		private var _fresnel:Boolean;
		private var texture:AGALTexture;
		private var reflectionConst:AGALConstant;
		
		/**
		 * コンストラクタ
		 * @param	resource	キューブマップリソース
		 * @param	reflection	基本反射率
		 * @param	fresnel	フレネル効果を適用するか。フレネル反射率が基本反射率に乗算される。事前にFresnelShaderを適用している必要がある。
		 * @param	blendMode	合成モード。通常反射の場合はBlendMode.NORMAL。
		 */
		public function EnvironmentShader(resource:TextureResource, reflection:Number, fresnel:Boolean, blendMode:String = BlendMode.NORMAL) 
		{
			super();
			
			requiredAttribute.push(VertexAttribute.NORMAL);
			
			_reflection = reflection;
			_fresnel = fresnel;
			_blendMode = blendMode;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
			
			this.resource = resource;
		}
		
		override public function getKey():String 
		{
			return "EnvironmentShader:" + _fresnel + "_" + _blendMode;
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaTransform = AlphaTransform.UNCHANGE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
			
			texture = fragmentCode.addTexture("&cube", null, this);
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
			reflectionConst = fragmentCode.addConstantsFromArray("@cubeReflection", [_reflection, 1 - _reflection, 0, 0]);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			fragmentConstants.number = true;
			fragmentConstants.cameraPosition = true;
			var tag:String = texture.getOptionCube(Smoothing.LINEAR, Mipmap.MIPLINEAR, Tiling.CLAMP);
			fragmentCode.addCode([
				"var $temp",
				"var $eye",
				//視点からピクセルへのベクトル
				"$eye.xyz = #wpos.xyz - @cameraPosition.xyz",
				"$temp.xyz = $normal.xyz",
				"$temp.w = dp3($eye.xyz, $normal.xyz)",
				"$temp.xyz *= $temp.w",
				"$temp.xyz *= @2",
				"$eye.xyz = $eye.xzy - $temp.xzy",
				"$eye.xyz = nrm($eye.xyz)",
				
				"$temp.xyz = tex($eye.xyz, &cube " + tag + ")"
			]);
			if (_fresnel)
			{
				//反射
				fragmentCode.addCode([
					"$eye.x = @cubeReflection.x * $common.w",
					"$eye.y = @1 - $eye.x"
				]);
				switch(_blendMode)
				{
					case BlendMode.MULTIPLY:
						fragmentCode.addCode([
							"$temp.xyz *= $eye.x",
							"$temp.xyz += $eye.yyy",
							"$output.xyz *= $temp.xyz"
						]);
						break;
					case BlendMode.ADD:
						fragmentCode.addCode([
							"$temp.xyz *= $eye.x",
							"$output.xyz += $temp.xyz"
						]);
						break;
					default:
						fragmentCode.addCode([
							"$output.xyz *= $eye.y",
							"$temp.xyz *= $eye.x",
							"$output.xyz += $temp.xyz"
						]);
						break;
				}
			}
			else
			{
				switch(_blendMode)
				{
					case BlendMode.MULTIPLY:
						fragmentCode.addCode([
							"$temp.xyz *= @cubeReflection.x",
							"$temp.xyz += @cubeReflection.yyy",
							"$output.xyz *= $temp.xyz"
						]);
						break;
					case BlendMode.ADD:
						fragmentCode.addCode([
							"$temp.xyz *= @cubeReflection.x",
							"$output.xyz += $temp.xyz"
						]);
						break;
					default:
						fragmentCode.addCode([
							"$output.xyz *= @cubeReflection.y",
							"$temp.xyz *= @cubeReflection.x",
							"$output.xyz += $temp.xyz"
						]);
						break;
				}
			}
			
			
		}
		
		override public function reference():MaterialShader 
		{
			return new EnvironmentShader(resource, _reflection, _fresnel, _blendMode);
		}
		
		override public function clone():MaterialShader 
		{
			return new EnvironmentShader(cloneTexture(resource), _reflection, _fresnel, _blendMode);
		}
		
		/**
		 * キューブマップリソース
		 */
		public function get resource():TextureResource 
		{
			return texture.texture;
		}
		
		public function set resource(value:TextureResource):void 
		{
			texture.texture = value;
			/*
			//関連付けられていたパースイベントを解除しておく
			if (_resource) _resource.removeEventListener(Event3D.RESOURCE_PARSED, image_parsedHandler);
			
			//テクスチャリソースの差し替え
			_resource = value;
			if (texture) texture.texture = _resource;
			
			//新しいパースイベントを関連付ける
			if (_resource) _resource.addEventListener(Event3D.RESOURCE_PARSED, image_parsedHandler);
			*/
			updateAlphaMode();
		}
		/*
		private function image_parsedHandler(e:Event3D):void 
		{
			updateAlphaMode();
		}
		*/
		/**
		 * 基本反射率
		 */
		public function get reflection():Number 
		{
			return _reflection;
		}
		
		public function set reflection(value:Number):void 
		{
			_reflection = value;
			if (reflectionConst)
			{
				reflectionConst.x = _reflection;
				reflectionConst.y = 1 - _reflection;
			}
		}
		
		/**
		 * 合成モード
		 */
		public function get blendMode():String 
		{
			return _blendMode;
		}
		
		public function set blendMode(value:String):void 
		{
			_blendMode = value;
			updateShaderCode();
		}
		
		/**
		 * フレネル効果を適当するかどうか
		 */
		public function get fresnel():Boolean 
		{
			return _fresnel;
		}
		
		public function set fresnel(value:Boolean):void 
		{
			_fresnel = value;
			updateShaderCode();
		}
		
	}

}