package net.morocoshi.moja3d.view 
{
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.system.Capabilities;
	import flash.utils.getTimer;
	import net.morocoshi.common.math.geom.Vector3DUtil;
	import net.morocoshi.common.math.transform.TransformUtil;
	import net.morocoshi.common.ui.mouse.FPVController;
	import net.morocoshi.common.ui.mouse.MouseDrag3D;
	import net.morocoshi.moja3d.billboard.BillboardManager;
	import net.morocoshi.moja3d.config.LightSetting;
	import net.morocoshi.moja3d.dialogs.SoftwareDialog;
	import net.morocoshi.moja3d.events.Event3D;
	import net.morocoshi.moja3d.filters.Filter3D;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.objects.Camera3D;
	import net.morocoshi.moja3d.objects.Light3D;
	import net.morocoshi.moja3d.objects.Object3D;
	import net.morocoshi.moja3d.objects.Shadow;
	import net.morocoshi.moja3d.overlay.objects.Object2D;
	import net.morocoshi.moja3d.renderer.PostEffectManager;
	import net.morocoshi.moja3d.renderer.RenderCollector;
	import net.morocoshi.moja3d.renderer.Renderer;
	import net.morocoshi.moja3d.renderer.RenderPhase;
	import net.morocoshi.moja3d.resources.ImageTextureResource;
	import net.morocoshi.moja3d.resources.RenderTextureResource;
	import net.morocoshi.moja3d.resources.Resource;
	import net.morocoshi.moja3d.resources.TextureResource;
	import net.morocoshi.moja3d.stats.MojaStats;
	
	use namespace moja3d;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class Scene3D extends EventDispatcher
	{
		public var root:Object3D;
		
		public var view:Viewport;
		public var renderer:Renderer;
		public var stage3D:Stage3D;
		public var context3D:ContextProxy;
		public var camera:Camera3D;
		
		public var driverInfo:DriverInfo;
		public var collector:RenderCollector;
		
		public var filters:Vector.<Filter3D>;
		public var postEffect:PostEffectManager;
		public var overlay:Object2D;
		public var billboard:BillboardManager;
		public var billboardUpAxis:Vector3D;
		
		public var tpv:MouseDrag3D;
		public var fpv:FPVController;
		
		private var _stats:MojaStats;
		private var sprite:Sprite;
		
		private var reflectCamera:Camera3D;
		private var filterTexture1:TextureResource;
		private var filterTexture2:TextureResource;
		private var stage:Stage;
		private var dispatchedComplete:Boolean;
		private var validFilters:Vector.<Filter3D>;
		private var viewRect:Rectangle;
		private var fillMaskTextureOrder:Boolean;
		moja3d var dispatchRenderEventEnabled:Boolean;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function Scene3D() 
		{
			dispatchRenderEventEnabled = true;
			dispatchedComplete = false;
			fillMaskTextureOrder = true;
			viewRect = new Rectangle(0, 0, 0, 0);
			renderer = new Renderer();
			renderer.scene = this;
			context3D = new ContextProxy();
			collector = new RenderCollector();
			collector.renderer = renderer;
			
			billboard = new BillboardManager();
			billboardUpAxis = Vector3D.Z_AXIS;
			
			postEffect = new PostEffectManager();
			postEffect.scene = this;
			postEffect.collector = collector;
			postEffect.renderer = renderer;
			
			overlay = new Object2D();
			overlay.name = "overlay";
			root = new Object3D();
			root.name = "root";
			_stats = new MojaStats();
			
			reflectCamera = new Camera3D();
			reflectCamera.name = "ReflectedCamera";
			camera = new Camera3D();
			camera.setPositionXYZ(0, 200, 0);
			camera.lookAtXYZ(0, 0, 0);
			camera.name = "MainCamera";
			camera.fovX = 80 / 180 * Math.PI;
			camera.fovY = 60 / 180 * Math.PI;
			camera.zNear = 0.2;
			camera.zFar = 10000;
			
			sprite = new Sprite();
			view = new Viewport();
			view.setSize(800, 600);
			filters = new Vector.<Filter3D>;
			validFilters = new Vector.<Filter3D>;
		}
		
		//--------------------------------------------------------------------------
		//
		//  初期化
		//
		//--------------------------------------------------------------------------
		
		public function setFPVController(obj:InteractiveObject, horizontal:Boolean = false, moveSpeed:Number = 10, x:Number = 0, y:Number = 0, z:Number = 0):void
		{
			if (tpv)
			{
				tpv.dispose();
				tpv = null;
			}
			
			fpv = new FPVController();
			fpv.init(obj);
			fpv.onMove = fpv_moveHandler;
			fpv.moveSpeed = moveSpeed;
			fpv.horizontal = horizontal;
			fpv.position.x = x;
			fpv.position.y = y;
			fpv.position.z = z;
		}
		
		public function setTPVController(obj:InteractiveObject, rotation:Number = -90, angle:Number = 45, distance:Number = 100, x:Number = 0, y:Number = 0, z:Number = 0):void
		{
			if (fpv)
			{
				fpv.dispose();
				fpv = null;
			}
			
			tpv = new MouseDrag3D();
			tpv.init(obj, rotation, angle, distance);
			tpv.onMovePosition = tpv_moveHandler;
			tpv.gazeAtXYZ(x, y, z, false, true);
		}
		
		private function fpv_moveHandler():void
		{
			camera.setPosition3D(fpv.position);
			camera.lookAt3D(fpv.position.add(Vector3DUtil.getScaled(fpv.front, 1000)));
		}
		
		private function tpv_moveHandler():void 
		{
			camera.setPosition3D(tpv.position);
			camera.lookAt3D(tpv.gazePosition);
		}
		
		/**
		 * Stage3Dを初期化します。うまくいくとEvent.COMPLETEが発行されます。
		 * @param	stage3D
		 * @param	width
		 * @param	height
		 * @param	antiAlias
		 * @param	renderMode	Context3DRenderMode.AUTO
		 * @param	profile		Context3DProfile.BASELINE
		 */
		public function init(stage3D:Stage3D, renderMode:String = "auto", profile:String = "baseline"):void
		{
			this.stage3D = stage3D;
			view.setStage3D(stage3D);
			collector.setProfile(profile);
			
			if (stage3D.context3D == null)
			{
				stage3D.addEventListener(ErrorEvent.ERROR, stage3D_errorHandler);
				stage3D.addEventListener(IOErrorEvent.IO_ERROR, stage3D_errorHandler);
				stage3D.addEventListener(Event.CONTEXT3D_CREATE, stage3D_contextCreateHandler);
				var args:Array = [renderMode, profile];
				args.length = Math.min(args.length, stage3D.requestContext3D.length);
				//stage3D.requestContext3DMatchingProfiles(Vector.<String>([profile, Context3DProfile.BASELINE_EXTENDED, Context3DProfile.BASELINE]));
				stage3D.requestContext3D.apply(null, args);
			}
			else
			{
				stage3D_contextCreateHandler(null);
			}
		}
		
		private function stage3D_errorHandler(e:ErrorEvent):void 
		{
			trace(e.text);
		}
		
		private function stage3D_contextCreateHandler(e:Event):void 
		{
			context3D.context = stage3D.context3D;
			context3D.context.enableErrorChecking = false;
			context3D.driver = new DriverInfo(context3D.context.driverInfo);
			_stats.setDriverInfo(context3D.driver);
			
			var dummyPattern:BitmapData = new BitmapData(64, 64, false, 0x222222);
			dummyPattern.fillRect(new Rectangle(0, 0, 32, 32), 0x808080);
			dummyPattern.fillRect(new Rectangle(32, 32, 32, 32), 0x808080);
			renderer.dummyTexture = new ImageTextureResource(dummyPattern);
			renderer.dummyTexture.upload(context3D, false);
			
			collector.filterGeometry.upload(context3D, false);
			collector.planeGeometry.upload(context3D, false);
			collector.reflectiveWater.setContext3D(context3D);
			
			for each(var resource:Resource in root.getResources(true))
			{
				resource.dispose();
				resource.upload(context3D, false);
			}
			
			if (dispatchedComplete == false)
			{
				dispatchedComplete = true;
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  描画
		//
		//--------------------------------------------------------------------------
		
		/**
		 * デフォルトのカメラ、ビューポート、ポストエフェクトを使ってrootオブジェクトをレンダリングする
		 */
		public function render():void
		{
			renderSceneTo(null, root, overlay, camera, view, filters);
		}
		
		/**
		 * 現在のレンダリング設定で画面をキャプチャする
		 * @param	transparent	背景を透過するか
		 * @param	hasOverlay	2Dレイヤーもキャプチャするか
		 * @param	dispatchRenderEvent	主にStarlingレイヤー描画用に使うEvent3D.CONTEXT_POST_CLEARとEvent3D.CONTEXT_PRE_PRESENTをdispatchするか
		 * @return
		 */
		public function capture(transparent:Boolean, hasOverlay:Boolean, dispatchRenderEvent:Boolean):BitmapData
		{
			var bitmapData:BitmapData = new BitmapData(view.width, view.height, transparent, 0x0);
			collector.captureDestination = bitmapData;
			var backgroundColor:Number = view.backgroundColor;
			var backgroundAlpha:Number = view.backgroundAlpha;
			if (transparent) view.backgroundColor = 0;
			view.backgroundAlpha = 0;
			dispatchRenderEventEnabled = dispatchRenderEvent;
			renderSceneTo(null, root, hasOverlay? overlay : null, camera, view, filters);
			dispatchRenderEventEnabled = true;
			collector.captureDestination = null;
			view.backgroundAlpha = backgroundAlpha;
			view.backgroundColor = backgroundColor;
			return bitmapData;
		}
		
		/**
		 * カメラ、ビューポート、ポストエフェクト、レンダリング対象を設定してレンダリングする
		 * @param	texture	テクスチャにレンダリングする場合は設定する。そうでなければnull。
		 * @param	rootObject	このオブジェクト以下がレンダリングされる
		 * @param	overlay
		 * @param	camera	カメラ
		 * @param	view	ビューポート
		 * @param	filters	ポストエフェクト
		 */
		public function renderSceneTo(texture:RenderTextureResource, rootObject:Object3D, overlay:Object2D, camera:Camera3D, view:Viewport, filters:Vector.<Filter3D>):void
		{
			LightSetting.renderInitialized = true;
			
			billboard.lookAtCamera(camera, billboardUpAxis);
			
			dispatchEvent(new Event3D(Event3D.PRE_RENDER));
			
			//Stage3Dが破棄されている場合があるかもしれない
			if (stage3D == null || context3D == null || context3D.context.driverInfo == DriverInfo.DISPOSED)
			{
				return;
			}
			
			//ポストエフェクトなどに使うテクスチャをビューサイズを元に生成したりリサイズしたりする。
			if (viewRect.width != view.width || viewRect.height != view.height)
			{
				viewRect.width = view.width;
				viewRect.height = view.height;
				postEffect.setViewSize(context3D, view.width, view.height);
				collector.reflectiveWater.setSize(view.width, view.height);
			}
			
			var i:int;
			var n:int;
			var shadow:Shadow;
			var light:Light3D;
			
			var t:int = getTimer();
			
			//背景
			if (view.updateBackBuffer)
			{
				context3D.context.configureBackBuffer(view.width, view.height, view.antiAlias, true);
				view.updateBackBuffer = false;
			}
			
			collector.context3D = context3D;
			
			//反射オブジェクトや影ライトの有無をチェック
			collector.collect(rootObject, camera, this, RenderPhase.CHECK);
			
			//シャドウライトを視野台を包むように自動移動
			if (collector.hasShadowElement || collector.hasLightElement)
			{
				var numShadow:int = collector.sunShadowList.length;
				for (i = 0; i < numShadow; i++) 
				{
					var shadowLight:Light3D = collector.sunShadowList[i];
					for (var j:int = 0; j < 2; j++) 
					{
						var isMain:Boolean = (j == 0);
						shadow = isMain? shadowLight._mainShadow : shadowLight._wideShadow;
						
						if (shadow)
						{
							if (shadowLight.autoShadowBounds)
							{
								var invertedMatrix:Matrix3D = shadow.parent.worldMatrix.clone();
								invertedMatrix.invert();
								invertedMatrix.prepend(camera.worldMatrix);
								
								var cos:Number = Math.cos(camera.fovY / 2);
								var near:Number = isMain? camera.zNear : shadowLight._mainShadow.radiusNear * cos;
								var far:Number = shadow.radiusFar / cos;
								camera.updateFrustumPoints(near, far);
								
								var minX:Number = Number.MAX_VALUE;
								var minY:Number = Number.MAX_VALUE;
								var minZ:Number = Number.MAX_VALUE;
								var maxX:Number = -Number.MAX_VALUE;
								var maxY:Number = -Number.MAX_VALUE;
								var maxZ:Number = -Number.MAX_VALUE;
								var numPoints:int = camera.frustumPoints.length;
								for (var k:int = 0; k < numPoints; k++)
								{
									var point:Vector3D = camera.frustumPoints[k];
									TransformUtil.transformVector(point, invertedMatrix);
									if(minX > point.x) minX = point.x;
									if(minY > point.y) minY = point.y;
									if(minZ > point.z) minZ = point.z;
									if(maxX < point.x) maxX = point.x;
									if(maxY < point.y) maxY = point.y;
									if(maxZ < point.z) maxZ = point.z;
								}
								
								shadow.height = shadow.width = Math.max(maxX - minX, maxY - minY);
								shadow.x = (maxX + minX) * 0.5;
								shadow.y = (maxY + minY) * 0.5;
								shadow.z = (maxZ + minZ) * 0.5;
								shadow.calculteWorldMatrix();
							}
							
							if (shadow.debug)
							{
								shadow.updateDebugModel();
							}
						}
					}
				}	
			}
			
			//有効なフィルタを抽出
			validFilters.length = 0;
			n = filters? filters.length : 0;
			for (i = 0; i < n; i++) 
			{
				var filter:Filter3D = filters[i];
				if (filter.enabled && !(filter.hasMaskElement && collector.hasMaskElement == false))
				{
					validFilters.push(filter);
				}
			}
			
			//マスク画像のレンダリング
			if (collector.hasMaskElement)
			{
				fillMaskTextureOrder = true;
				renderer.renderScene(collector, camera, postEffect.maskTexture, null, 0x000000, 1, view.antiAlias);
			}
			else if (fillMaskTextureOrder == true)
			{
				fillMaskTextureOrder = false;
				postEffect.maskTexture.fillColor(context3D, 0x0);
			}
			
			//光の投影
			if (collector.hasLightElement)
			{
				n = collector.sunShadowList.length;
				for (i = 0; i < n; i++) 
				{
					light = collector.sunShadowList[i];
					collector.collect(rootObject, light._mainShadow, this, RenderPhase.LIGHT);
					renderer.renderLightMap(collector, light._mainShadow);
					if (light._wideShadow)
					{
						collector.collect(rootObject, light._wideShadow, this, RenderPhase.LIGHT);
						renderer.renderLightMap(collector, light._wideShadow);
					}
				}
			}
			
			//デプスシャドウ
			if (collector.hasShadowElement)
			{
				n = collector.sunShadowList.length;
				for (i = 0; i < n; i++) 
				{
					light = collector.sunShadowList[i];
					collector.collect(rootObject, light._mainShadow, this, RenderPhase.DEPTH);
					renderer.renderShadowMap(collector, light._mainShadow);
					if (light._wideShadow)
					{
						collector.collect(rootObject, light._wideShadow, this, RenderPhase.DEPTH);
						renderer.renderShadowMap(collector, light._wideShadow);
					}
				}
			}
			
			//反射
			var cameraZ:Number = camera._worldMatrix.position.z;
			var hasReflectElement:Boolean = collector.reflectiveWater.hasReflectElement;
			if (hasReflectElement)
			{
				var reflectionData:Object = collector.reflectiveWater.agalTextures;
				for (var waterHeight:* in reflectionData) 
				{
					waterHeight = Number(waterHeight);
					var reflectionResource:RenderTextureResource = reflectionData[waterHeight];
					//反射用Killシェーダのパラメータを水面の高さに合わせる
					collector.reflectiveWater.killShader.height = waterHeight;
					collector.reflectiveWater.killShader.reverse = cameraZ < waterHeight;
					
					//姿勢更新（@@@メインカメラがroot以外に置かれているとおかしくなるのでなんとかしたい）
					reflectCamera.x = camera.x;
					reflectCamera.y = camera.y;
					reflectCamera.z = -(cameraZ - waterHeight) + waterHeight;
					reflectCamera.rotationX = Math.PI - camera.rotationX;
					reflectCamera.rotationY = camera.rotationY;
					reflectCamera.rotationZ = camera.rotationZ;
					reflectCamera.scaleX = camera.scaleX;
					reflectCamera.scaleY = camera.scaleY;
					reflectCamera.scaleZ = camera.scaleZ;
					
					reflectCamera.orthographic = camera.orthographic;
					reflectCamera.width = camera.width;
					reflectCamera.height = camera.height;
					reflectCamera.fovX = camera.fovX;
					reflectCamera.fovY = camera.fovY;
					reflectCamera.zNear = camera.zNear;
					reflectCamera.zFar = camera.zFar;
					
					reflectCamera.calculteWorldMatrix();
					
					//反射モデル収集
					collector.collect(rootObject, reflectCamera, this, RenderPhase.REFLECT);
					renderer.renderScene(collector, reflectCamera, reflectionResource, null, view.backgroundColor, view.backgroundAlpha, view.antiAlias);
				}
			}
			
			//最終結果
			collector.collect(rootObject, camera, this, RenderPhase.NORMAL);
			if (overlay)
			{
				collector.collect2D(overlay, this, RenderPhase.OVERLAY);
			}
			var targetTexture:RenderTextureResource = (validFilters.length > 0)? postEffect.renderTexture : texture;
			renderer.renderScene(collector, camera, targetTexture, null, view.backgroundColor, view.backgroundAlpha, view.antiAlias);
			
			//ポストエフェクト
			n = validFilters.length;
			if (n > 0)
			{
				postEffect.antiAlias = view.antiAlias;
				postEffect.start();
				for (i = 0; i < n; i++) 
				{
					if (i == n - 1)
					{
						postEffect.end();
					}
					validFilters[i].render(postEffect);
				}
			}
			
			if (texture == null)
			{
				_stats.apply(collector);
				if (dispatchRenderEventEnabled)
				{
					dispatchEvent(new Event3D(Event3D.CONTEXT_PRE_PRESENT));
				}
				if (collector.captureDestination)
				{
					context3D.context.drawToBitmapData(collector.captureDestination);
				}
				context3D.context.present();
				collector.resetStats();
			}
			
			dispatchEvent(new Event3D(Event3D.POST_RENDER));
		}
		
		/**
		 * 毎フレームrender()を呼び出すのを開始する
		 */
		public function startRendering():void 
		{
			sprite.addEventListener(Event.ENTER_FRAME, sprite_enterFrameHandler);
		}
		
		/**
		 * 毎フレームrender()を呼び出すのを停止する
		 */
		public function stopRendering():void
		{
			sprite.removeEventListener(Event.ENTER_FRAME, sprite_enterFrameHandler);
		}
		
		/**
		 * ソフトウェアモードだった場合、メッセージを表示する
		 * @param	container
		 * @param	center
		 * @param	x
		 * @param	y
		 * @return
		 */
		public function checkSoftwareMode(container:DisplayObjectContainer, center:Boolean, x:Number = 0, y:Number = 0):SoftwareDialog 
		{
			var open:Boolean = Capabilities.language == "ja" && driverInfo.isSoftware && driverInfo.softwareType == DriverInfo.USER_DISABLED;
			
			if (open == false) return null;
			
			var dialog:SoftwareDialog = new SoftwareDialog();
			container.addChild(dialog);
			if (center == false)
			{
				dialog.x = x;
				dialog.y = y;
			}
			else
			{
				dialog.visible = false;
				dialog.autoAlignCenter();
			}
			
			return dialog;
		}
		
		/**
		 * マウスクリック時の処理
		 */
		public function mouseClick(mouseX:Number, mouseY:Number):void 
		{
			var fov:Number = camera.getVerticalFOV();
			var asp:Number = camera.getScreenAspect();
			var h:Number = Math.tan(fov / 2);
			var tx:Number = ((mouseX - view.x) / view.width - 0.5) * 2 * h * asp;
			var ty:Number = ((mouseY - view.y) / view.height - 0.5) * 2 * -h;
			
			var start:Vector3D = camera.getPosition();
			var end:Vector3D = start.clone();
			var front:Vector3D = camera.getWorldAxisZ(true);
			var right:Vector3D = camera.getWorldAxisX(true);
			var top:Vector3D = camera.getWorldAxisY(true);
			
			var distance:Number = 25;
			front.scaleBy(-distance);
			right.scaleBy(distance * tx);
			top.scaleBy(distance * ty);
			end.incrementBy(front);
			end.incrementBy(right);
			end.incrementBy(top);
			
			root.intersectRay(start, end, true);
			//root.addChild(new Cube(1, 1, 1, 1, 1, 1, new FillMaterial(0xff0000, 1, false))).setPosition3D(end);
			//root.upload(context3D, true, true);
		}
		
		private function sprite_enterFrameHandler(e:Event):void 
		{
			render();
		}
		
		//--------------------------------------------------------------------------
		//
		//  getter/setter
		//
		//--------------------------------------------------------------------------
		
		public function get stats():MojaStats 
		{
			return _stats;
		}
		
	}

}