package net.morocoshi.moja3d.renderer 
{
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.utils.Dictionary;
	import net.morocoshi.moja3d.agal.AGALCode;
	import net.morocoshi.moja3d.agal.AGALInfo;
	import net.morocoshi.moja3d.agal.BasicConstant;
	import net.morocoshi.moja3d.agal.DirectionalLightConstant;
	import net.morocoshi.moja3d.agal.OmniLightConstant;
	import net.morocoshi.moja3d.agal.ShadowConstant;
	import net.morocoshi.moja3d.agal.UsingConstants;
	import net.morocoshi.moja3d.config.LightSetting;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.objects.AmbientLight;
	import net.morocoshi.moja3d.objects.Camera3D;
	import net.morocoshi.moja3d.objects.DirectionalLight;
	import net.morocoshi.moja3d.objects.Light3D;
	import net.morocoshi.moja3d.objects.Object3D;
	import net.morocoshi.moja3d.objects.OmniLight;
	import net.morocoshi.moja3d.objects.Shadow;
	import net.morocoshi.moja3d.overlay.objects.Object2D;
	import net.morocoshi.moja3d.resources.FilterGeometry;
	import net.morocoshi.moja3d.resources.Plane2DGeometry;
	import net.morocoshi.moja3d.shaders.render.FillShader;
	import net.morocoshi.moja3d.shaders.render.ReflectionShader;
	import net.morocoshi.moja3d.shaders.ShaderList;
	import net.morocoshi.moja3d.shaders.shadow.ShadowShader;
	import net.morocoshi.moja3d.view.Scene3D;
	
	use namespace moja3d;
	
	/**
	 * レンダリング要素を収集したりする
	 * 
	 * @author tencho
	 */
	public class RenderCollector 
	{
		public var context3D:Context3D;
		public var renderer:Renderer;
		public var renderElementList:Object;
		public var camera:Camera3D;
		
		public var vertexCode:AGALCode;
		public var fragmentCode:AGALCode;
		public var vertexConstant:BasicConstant;
		public var fragmentConstant:BasicConstant;
		public var sunLightConstantList:Vector.<DirectionalLightConstant>;
		public var omniLightConstantList:Vector.<OmniLightConstant>;
		public var shadowConstantList:Vector.<ShadowConstant>;
		
		public var renderPhase:String;
		public var sunLightList:Vector.<DirectionalLight>;
		public var omniLightList:Vector.<OmniLight>;
		public var sunShadowList:Vector.<DirectionalLight>;
		
		public var filterGeometry:FilterGeometry;
		public var planeGeometry:Plane2DGeometry;
		
		private var _drawCount:int = 0;
		private var _polygonCount:int = 0;
		private var _alphaCount:int = 0;
		private var shadowShaderLink:Dictionary;
		moja3d var _moveCount:int = 0;
		moja3d var _colorCount:int = 0;
		
		/**水面反射関連*/
		public var reflectiveWater:ReflectiveWater;
		
		/**影要素があったか*/
		public var hasShadowElement:Boolean;
		/**光要素があったか*/
		public var hasLightElement:Boolean;
		/**マスク要素があったか*/
		public var hasMaskElement:Boolean;
		public var maskShaderLink:Object;
		
		public var opaquePassShaderList:ShaderList;
		public var alphaPassShaderList:ShaderList;
		/**Object3Dのカラー設定の有効設定。有効にすると自動的にカラーシェーダーが追加される。*/
		public var useObjectColorTransform:Boolean = true;
		public var info:AGALInfo;
		/**これにBitmapDataが指定されていればここにキャプチャする*/
		public var captureDestination:BitmapData;
		
		/**
		 * レンダリング時にシーン内のものを色々と収集する
		 */
		public function RenderCollector() 
		{
			shadowShaderLink = new Dictionary();
			reflectiveWater = new ReflectiveWater();
			sunLightList = new Vector.<DirectionalLight>;
			omniLightList = new Vector.<OmniLight>;
			sunShadowList = new Vector.<DirectionalLight>;
			sunLightConstantList = new Vector.<DirectionalLightConstant>;
			omniLightConstantList = new Vector.<OmniLightConstant>;
			shadowConstantList = new Vector.<ShadowConstant>;
			vertexCode = new AGALCode(Context3DProgramType.VERTEX);
			fragmentCode = new AGALCode(Context3DProgramType.FRAGMENT);
			filterGeometry = new FilterGeometry();
			planeGeometry = new Plane2DGeometry();
			maskShaderLink = { };
		}
		
		public function get drawCount():int 
		{
			return _drawCount;
		}
		
		public function get moveCount():int 
		{
			return _moveCount;
		}
		
		public function get polygonCount():int 
		{
			return _polygonCount;
		}
		
		public function get alphaCount():int 
		{
			return _alphaCount;
		}
		
		public function get colorCount():int 
		{
			return _colorCount;
		}
		
		/**
		 * 
		 * @param	context3D
		 */
		public function setContext3D(context3D:Context3D):void 
		{
			this.context3D = context3D;
		}
		
		/**
		 * 
		 * @param	profile
		 */
		public function setProfile(profile:String):void 
		{
			info = new AGALInfo(profile);
		}
		
		/**
		 * 指定Object3D以下の全ての子を辿ってレンダリング要素を収集する
		 * @param	root
		 * @param	phase
		 */
		public function collect(root:Object3D, camera:Camera3D, scene:Scene3D, phase:String):void 
		{
			renderPhase = phase;
			this.camera = camera;
			var shadow:Shadow = camera as Shadow;
			var w:Number = shadow? shadow.width : scene.view.width;
			var h:Number = shadow? shadow.height : scene.view.height;
			camera.setScreenSize(w, h);
			camera.checkPerspectiveUpdate();
			
			clear();
			
			setBasicContext();
			root.collectRenderElements(this, false, false, false, 1, root.containerRenderMask);
			
			complete();
		}
		
		public function collect2D(root:Object2D, scene:Scene3D, phase:String):void 
		{
			renderPhase = phase;
			root.collectRenderElements(this, false, false, 1);
		}
		
		/**
		 * 収集したライトから情報を整理
		 */
		private function complete():void
		{
			var i:int;
			var n:int;
			
			//収集した影ライト数だけ定数を更新する
			n = LightSetting._numDirectionalShadow;
			for (i = 0; i < n; i++)
			{
				var shadowConst:ShadowConstant = shadowConstantList[i];
				//@@@ここあってる？
				if (sunShadowList.length <= i)
				{
					shadowConst.clear();
					continue;
				}
				else
				{
					shadowConst.applyFrom(sunShadowList[i]);
				}
				
				//全影シェーダーの定数をライト影で更新
				for each(var shader:ShadowShader in shadowShaderLink)
				{
					var mainShadow:Shadow = sunShadowList[i]._mainShadow;
					var wideShadow:Shadow = sunShadowList[i]._wideShadow;
					
					if (shader.syncLight)
					{
						shader.mainBlur = mainShadow.blur;
						shader.mainSamples = mainShadow.numSamples;
						if (wideShadow)
						{
							shader.wideBlur = wideShadow.blur;
							shader.wideSamples = wideShadow.numSamples;
						}
					}
					shader.depthBias = mainShadow.depthBias / (mainShadow.zFar - mainShadow.zNear);
					shader.mainNear = mainShadow.radiusNear;
					shader.mainFar = mainShadow.radiusFar;
					shader.intensity = mainShadow.intensity;
					shader.useWideShadow = wideShadow != null;
					
					if (wideShadow)
					{
						shader.wideNear = wideShadow.radiusNear;
						shader.wideFar = wideShadow.radiusFar;
						if (shader.syncLight)
						{
							shader.wideBlur = wideShadow.blur;
						}
						shader.wideDepthBias = wideShadow.depthBias / (wideShadow.zFar - wideShadow.zNear);
					}
					
				}
			}
			
			//影ライトに通常ライトを連結して全ライトリストにする（影の順番を先にするため）
			sunLightList = sunShadowList.concat(sunLightList);
			
			//収集したライト数だけ定数を更新する
			for (i = 0; i < LightSetting._numDirectionalLights; i++) 
			{
				var light:DirectionalLightConstant = sunLightConstantList[i];
				if (sunLightList.length <= i)
				{
					light.clear();
					continue;
				}
				light.applyFrom(sunLightList[i]);
			}
			
			for (i = 0; i < LightSetting._numOmniLights; i++) 
			{
				var omniLight:OmniLightConstant = omniLightConstantList[i];
				if (omniLightList.length <= i)
				{
					omniLight.clear();
					continue;
				}
				omniLight.applyFrom(omniLightList[i]);
			}
		}
		
		public function resetStats():void
		{
			_drawCount = 0;
			_moveCount = 0;
			_colorCount = 0;
			_polygonCount = 0;
			_alphaCount = 0;
		}
		
		private function clear():void
		{
			hasShadowElement = false;
			hasLightElement = false;
			hasMaskElement = false;
			
			//反射要素チェックフェーズのみリセットしておく
			if (renderPhase == RenderPhase.CHECK)
			{
				reflectiveWater.clear();
			}
			//デプスレンダリング時はライト数が変化するとまずいので
			if (renderPhase != RenderPhase.DEPTH)
			{
				sunShadowList.length = 0;
				shadowShaderLink = new Dictionary();
				sunLightList.length = 0;
				omniLightList.length = 0;
			}
			renderElementList = {};
		}
		
		private function setBasicContext():void
		{
			vertexCode.clearAll();
			fragmentCode.clearAll();
			
			vertexConstant = new BasicConstant(vertexCode);
			fragmentConstant = new BasicConstant(fragmentCode);
			
			
			//ライトの上限数だけ生成
			sunLightConstantList.length = 0;
			omniLightConstantList.length = 0;
			shadowConstantList.length = 0;
			
			var i:int;
			var n:int;
			n = LightSetting._numDirectionalShadow;
			for (i = 0; i < n; i++)
			{
				shadowConstantList.push(new ShadowConstant(i, vertexCode, fragmentCode));
			}
			
			n = LightSetting._numDirectionalLights;
			for (i = 0; i < n; i++) 
			{
				sunLightConstantList.push(new DirectionalLightConstant(i, vertexCode, fragmentCode));
			}
			
			n = LightSetting._numOmniLights;
			for (i = 0; i < n; i++) 
			{
				omniLightConstantList.push(new OmniLightConstant(i, vertexCode, fragmentCode));
			}
		}
		
		/**
		 * ライトの追加。影があるかどうかで追加先が変わる
		 * @param	light
		 */
		public function addLight3D(light:Light3D):void
		{
			var hasShadow:Boolean = light._mainShadow != null;
			
			if (hasShadow)
			{
				//限界まで影ライトを追加する
				if (sunShadowList.length < LightSetting._numDirectionalShadow)
				{
					sunShadowList.push(light as DirectionalLight);
				}
				return;
			}
			
			//影がないライトの追加
			
			if (light is AmbientLight)
			{
				vertexConstant.ambient.x += light.r * light.intensity;
				vertexConstant.ambient.y += light.g * light.intensity;
				vertexConstant.ambient.z += light.b * light.intensity;
				fragmentConstant.ambient.x += light.r * light.intensity;
				fragmentConstant.ambient.y += light.g * light.intensity;
				fragmentConstant.ambient.z += light.b * light.intensity;
			}
			
			if (light is DirectionalLight)
			{
				if (sunLightList.length < LightSetting._numDirectionalLights)
				{
					sunLightList.push(light as DirectionalLight);
				}
			}
			
			if (light is OmniLight)
			{
				if (omniLightList.length < LightSetting._numOmniLights)
				{
					omniLightList.push(light as OmniLight);
				}
			}
		}
		
		public function addReflectElement(z:Number, reflectiveShader:ReflectionShader):void 
		{
			reflectiveShader.reflectionTexture.texture = reflectiveWater.addReflectElement(z, reflectiveShader);
		}
		
		/**
		 * レンダリング要素を追加する
		 * 各レイヤーごとにリストを管理する
		 * @param	item
		 */
		public function addRenderElement(item:RenderElement):void 
		{
			_polygonCount += item.numTriangles;
			_drawCount++;
			
			var shadow:ShadowShader = item.shaderList.shadowShader;
			if (shadow)
			{
				shadowShaderLink[shadow] = shadow;
			}
			
			if (item.layer == RenderLayer.TRANSPARENT)
			{
				_alphaCount++;
			}
			
			var list:RenderElement = renderElementList[item.layer];
			if (list == null)
			{
				renderElementList[item.layer] = item;
				item.next = null;
				return;
			}
			item.next = list;
			renderElementList[item.layer] = item;
		}
		
		private var element:RenderElement;
		public function collectFilter(shaderList:ShaderList):void 
		{
			clear();
			setBasicContext();
			
			if (element == null)
			{
				element = new RenderElement();
			}
			element.firstIndex = 0;
			element.numTriangles = 2;
			element.matrix = null;
			element.vertexBufferFormatList = filterGeometry.vertexBufferFormatList;
			element.vertexBufferList = filterGeometry.vertexBufferList;
			element.indexBuffer = filterGeometry.indexBuffer;
			element.culling = Context3DTriangleFace.FRONT;
			element.shaderList = shaderList;
			element.layer = RenderLayer.OPAQUE;
			element.name = "";
			element.sortPriority = 0;
			
			addRenderElement(element);
			
			complete();
		}
		
		/**
		 * 使用しているライト関連の定数をチェックして有効無効を切り替え
		 * @param	vertex
		 * @param	fragment
		 */
		public function applyLightConstant(vertex:UsingConstants, fragment:UsingConstants):void 
		{
			var i:int;
			var n:int;
			
			n = shadowConstantList.length;
			for (i = 0; i < n; i++) 
			{
				var shadow:ShadowConstant = shadowConstantList[i];
				shadow.setVertexEnabled(vertex.shadow && renderPhase != RenderPhase.DEPTH);
				shadow.setFragmentEnabled(fragment.shadow && renderPhase != RenderPhase.DEPTH);
			}
			
			n = sunLightConstantList.length;
			for (i = 0; i < n; i++) 
			{
				var sunLight:DirectionalLightConstant = sunLightConstantList[i];
				sunLight.setVertexEnabled(vertex.lights);
				sunLight.setFragmentEnabled(fragment.lights);
			}
			
			n = omniLightConstantList.length;
			for (i = 0; i < n; i++) 
			{
				var omniLight:OmniLightConstant = omniLightConstantList[i];
				omniLight.setVertexEnabled(vertex.lights);
				omniLight.setFragmentEnabled(fragment.lights);
			}
		}
		
		public function getMaskShaderList(mask:uint):ShaderList 
		{
			var result:ShaderList = maskShaderLink[mask];
			if (result == null)
			{
				result = maskShaderLink[mask] = new ShaderList();
				result.addShader(new FillShader(mask, 1));
			}
			return result;
		}
		
	}

}