package net.morocoshi.moja3d.renderer 
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DCompareMode;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import net.morocoshi.moja3d.agal.AGALCache;
	import net.morocoshi.moja3d.agal.AGALTexture;
	import net.morocoshi.moja3d.events.Event3D;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.objects.Camera3D;
	import net.morocoshi.moja3d.objects.Shadow;
	import net.morocoshi.moja3d.resources.RenderTextureResource;
	import net.morocoshi.moja3d.resources.TextureResource;
	import net.morocoshi.moja3d.view.Scene3D;
	import net.morocoshi.moja3d.view.Viewport;
	
	use namespace moja3d;
	
	/**
	 * レンダラー
	 * 
	 * @author tencho
	 */
	public class Renderer 
	{
		private var matrix:Matrix3D;
		private var renderElementList:RenderElement;
		public var scene:Scene3D;
		//private var viewMatrix:Matrix3D = new Matrix3D();
		private var elementSort:RenderElementSort;
		
		//レンダリング毎にシェーダーのtickを呼び出すのに使う
		private var frame:int;
		
		/**テクスチャリソースが無かった時に使う仮テクスチャ*/
		public var dummyTexture:TextureResource;
		
		public function Renderer() 
		{
			frame = 0;
			elementSort = new RenderElementSort();
			matrix = new Matrix3D();
		}
		
		public function renderTexture(textures:Array, collector:RenderCollector, view:Viewport, clipEnabled:Boolean, target:RenderTextureResource, rgb:uint, alpha:Number, antiAlias:int):void
		{
			renderScene(collector, view, clipEnabled, null, target, textures, rgb, alpha, antiAlias, false);
		}
		
		public function renderShadowMap(collector:RenderCollector, shadow:Shadow):void 
		{
			//TODO: アンチエイリアスは1固定で大丈夫？
			shadow.readyShadowTexture(collector.context3D);
			renderScene(collector, scene.view, true, shadow, shadow.shadowTexture, null, 0xffffff, 1, 1, false);
		}
		
		public function renderLightMap(collector:RenderCollector, shadow:Shadow):void 
		{
			//TODO: アンチエイリアスは1固定で大丈夫？
			shadow.readyLightTexture(collector.context3D);
			renderScene(collector, scene.view, true, shadow, shadow.lightTexture, null, 0xffffff, 1, 1, false);
		}
		
		private var lastTarget:RenderTextureResource = new RenderTextureResource();
		/**
		 * 
		 * @param	collector	事前に収集しておいたメッシュとか
		 * @param	view	ビューポート
		 * @param	clipEnabled	クリッピングを行うか
		 * @param	camera	カメラ
		 * @param	target	テクスチャに描画したい場合に使う
		 * @param	drawTexture	主にフィルターに使う素材用テクスチャリスト
		 * @param	rgb	背景色
		 * @param	alpha	背景アルファ
		 */
		public function renderScene(collector:RenderCollector, view:Viewport, clipEnabled:Boolean, camera:Camera3D, target:RenderTextureResource, drawTextures:Array, rgb:uint, alpha:Number, antiAlias:int, dispatchRenderEvent:Boolean):void
		{
			var context:Context3D = collector.context3D.context;
			var cameraMatrix:Matrix3D;
			
			frame++;
			if (camera)
			{
				var clipRect:Rectangle = (target == null || clipEnabled == false) && view? view.clipping : null;
				camera.checkPerspectiveUpdate(clipRect, clipEnabled);
				collector.vertexConstant.clipping.x = camera.zNear;
				collector.vertexConstant.clipping.y = camera.zFar;
				collector.vertexConstant.clipping.z = camera.zFar - camera.zNear;
				collector.fragmentConstant.clipping.x = camera.zNear;
				collector.fragmentConstant.clipping.y = camera.zFar;
				collector.fragmentConstant.clipping.z = camera.zFar - camera.zNear;
				
				//各種行列
				collector.vertexConstant.viewMatrix.matrix = camera.viewMatrix;
				collector.vertexConstant.projMatrix.matrix = camera.perspectiveMatrix;
				collector.vertexConstant.clipMatrix.matrix = camera.clippingMatrix;
				collector.fragmentConstant.viewMatrix.matrix = camera.viewMatrix;
				collector.fragmentConstant.projMatrix.matrix = camera.perspectiveMatrix;
				collector.fragmentConstant.clipMatrix.matrix = camera.clippingMatrix;
				
				//カメラのワールド座標
				cameraMatrix = camera.worldMatrix;
				//ビューサイズに関係なく一定のサイズにできるようにする係数
				var viewScale:Number = scene.view.height / Math.tan(camera.getVerticalFOV(scene.view.clipping) * 0.5) * 0.5;
				collector.vertexConstant.cameraPosition.x = cameraMatrix.rawData[12];
				collector.vertexConstant.cameraPosition.y = cameraMatrix.rawData[13];
				collector.vertexConstant.cameraPosition.z = cameraMatrix.rawData[14];
				collector.vertexConstant.cameraPosition.w = viewScale;
				collector.fragmentConstant.cameraPosition.x = cameraMatrix.rawData[12];
				collector.fragmentConstant.cameraPosition.y = cameraMatrix.rawData[13];
				collector.fragmentConstant.cameraPosition.z = cameraMatrix.rawData[14];
				collector.fragmentConstant.cameraPosition.w = viewScale;
				//カメラの角度（Z軸ベクトル）
				collector.vertexConstant.cameraDirection.x = cameraMatrix.rawData[8];
				collector.vertexConstant.cameraDirection.y = cameraMatrix.rawData[9];
				collector.vertexConstant.cameraDirection.z = cameraMatrix.rawData[10];
				collector.vertexConstant.cameraDirection.normalize();
				collector.fragmentConstant.cameraDirection.x = -cameraMatrix.rawData[8];
				collector.fragmentConstant.cameraDirection.y = -cameraMatrix.rawData[9];
				collector.fragmentConstant.cameraDirection.z = -cameraMatrix.rawData[10];
				collector.fragmentConstant.cameraDirection.normalize();
			}
			
			collector.vertexConstant.viewSize.x = scene.view.width;
			collector.vertexConstant.viewSize.y = scene.view.height;
			collector.vertexConstant.viewSize.z = scene.view.clipping? scene.view.clipping.width : scene.view.width;
			collector.vertexConstant.viewSize.w = scene.view.clipping? scene.view.clipping.height : scene.view.height;
			collector.fragmentConstant.viewSize.x = scene.view.width;
			collector.fragmentConstant.viewSize.y = scene.view.height;
			collector.fragmentConstant.viewSize.z = scene.view.clipping? scene.view.clipping.width : scene.view.width;
			collector.fragmentConstant.viewSize.w = scene.view.clipping? scene.view.clipping.height : scene.view.height;
			
			//targetが指定されていればテクスチャにレンダリング
			if (lastTarget != target)
			{
				lastTarget = target;
				if (target)
				{
					context.setRenderToTexture(target.texture, true, antiAlias);
					target.isUploaded = true;
				}
				else
				{
					context.setRenderToBackBuffer();
				}
				
			}
			
			//背景色でクリア
			var r:Number = (rgb >> 16 & 0xff) / 0xff;
			var g:Number = (rgb >> 8 & 0xff) / 0xff;
			var b:Number = (rgb & 0xff) / 0xff;
			context.clear(r, g, b, alpha);
			
			if (target == null && dispatchRenderEvent)
			{
				scene.dispatchEvent(new Event3D(Event3D.CONTEXT_POST_CLEAR));
			}
			
			//クリッピング
			if (target == null && view.clipping && !(camera is Shadow))
			{
				context.setScissorRectangle(view.clipping);
				AGALCache.basicFilterShader.clippingConst.x = view.clipping.x;
				AGALCache.basicFilterShader.clippingConst.y = view.clipping.y;
				AGALCache.basicFilterShader.clippingConst.z = view.clipping.width;
				AGALCache.basicFilterShader.clippingConst.w = view.clipping.height;
				AGALCache.spriteEndShaderList.clippingConst.x = view.clipping.x;
				AGALCache.spriteEndShaderList.clippingConst.y = view.clipping.y;
				AGALCache.spriteEndShaderList.clippingConst.z = view.clipping.width;
				AGALCache.spriteEndShaderList.clippingConst.w = view.clipping.height;
			}
			else
			{
				context.setScissorRectangle(null);
				AGALCache.basicFilterShader.clippingConst.x = 0;
				AGALCache.basicFilterShader.clippingConst.y = 0;
				AGALCache.basicFilterShader.clippingConst.z = view.width;
				AGALCache.basicFilterShader.clippingConst.w = view.height;
				AGALCache.spriteEndShaderList.clippingConst.x = 0;
				AGALCache.spriteEndShaderList.clippingConst.y = 0;
				AGALCache.spriteEndShaderList.clippingConst.z = view.width;
				AGALCache.spriteEndShaderList.clippingConst.w = view.height;
			}
			
			//最背面要素のレンダリング
			if (collector.renderElementList[RenderLayer.BACKGROUND])
			{
				setDepthTest(context, false, Context3DCompareMode.ALWAYS);
				renderLayer(RenderLayer.BACKGROUND, collector, camera, drawTextures);
			}
			
			//不透明要素のレンダリング
			if (collector.renderElementList[RenderLayer.OPAQUE])
			{
				setDepthTest(context, true, Context3DCompareMode.LESS);
				renderLayer(RenderLayer.OPAQUE, collector, camera, drawTextures);
			}
			
			//半透明要素のレンダリング
			if (collector.renderElementList[RenderLayer.TRANSPARENT])
			{
				setDepthTest(context, false, Context3DCompareMode.LESS);
				sortItem(RenderLayer.TRANSPARENT, collector, camera);//カメラからの距離でソート
				renderLayer(RenderLayer.TRANSPARENT, collector, camera, drawTextures);
			}
			
			//最前面要素のレンダリング
			if (collector.renderElementList[RenderLayer.FOREFRONT])
			{
				setDepthTest(context, false, Context3DCompareMode.ALWAYS);
				renderLayer(RenderLayer.FOREFRONT, collector, camera, drawTextures);
			}
			
			//2Dオーバーレイのレンダリング
			if (collector.renderElementList[RenderLayer.OVERLAY])
			{
				context.setScissorRectangle(null);
				setDepthTest(context, false, Context3DCompareMode.ALWAYS);
				renderLayer(RenderLayer.OVERLAY, collector, camera, drawTextures);
			}
			
			context = null;
			cameraMatrix = null;
		}
		
		private function setDepthTest(context:Context3D, depthMask:Boolean, passCompareMode:String):void 
		{
			defaltPassCompareMode = passCompareMode;
			defaltDepthMask = depthMask;
			context.setDepthTest(depthMask, passCompareMode);
		}
		
		/**
		 * RenderElementをカメラ平面からの距離でソートする
		 * @param	layer
		 * @param	collector
		 * @param	camera
		 */
		public function sortItem(layer:int, collector:RenderCollector, camera:Camera3D):void
		{
			var data:Vector.<Number>;
			var item:RenderElement = collector.renderElementList[layer];
			while (item)
			{
				//カメラ平面からの距離をチェックする
				data = item.matrix.rawData;
				item.distance = camera.getDistanceXYZ(data[12], data[13], data[14]) - item.sortPriority;
				item = item.next;
			}
			collector.renderElementList[layer] = elementSort.sort(collector.renderElementList[layer]);
			data = null;
		}
		
		private var defaltPassCompareMode:String;
		private var defaltDepthMask:Boolean;
		private var tempPassCompareMode:String;
		private var tempDepthMask:Boolean;
		
		/**
		 * 
		 * @param	layer
		 * @param	collector
		 * @param	camera
		 * @param	drawTexture	フィルター用？
		 */
		public function renderLayer(layer:int, collector:RenderCollector, camera:Camera3D, drawTextures:Array):void
		{
			var textureList:Vector.<AGALTexture>;
			var textureResource:TextureResource;
			var agalTex:AGALTexture;
			var context:Context3D = collector.context3D.context;
			var timer:int = getTimer();
			
			var item:RenderElement = collector.renderElementList[layer];
			while (item)
			{
				var i:int;
				var n:int;
				//転送する定数をシェーダーリストから判別
				if (item.shaderList.updateConstantOrder)
				{
					item.shaderList.updateConstantList();
				}
				collector.applyLightConstant(item.shaderList.vertexUsingConstants, item.shaderList.fragmentUsingConstants);
				collector.vertexConstant.apply(item.shaderList.vertexUsingConstants);
				collector.fragmentConstant.apply(item.shaderList.fragmentUsingConstants);
				
				//頂点バッファ
				n = item.vertexBufferList.length;
				for (i = 0; i < n; i++) 
				{
					context.setVertexBufferAt(i, item.vertexBufferList[i], 0, item.vertexBufferFormatList[i]);
				}
				
				//テクスチャ
				textureList = collector.fragmentCode.textureList.concat(item.shaderList.fragmentCode.textureList);
				if (drawTextures)
				{
					var m:int = drawTextures.length;
					for (var j:int = m - 1; j >= 0; j--) 
					{
						textureList.unshift(new AGALTexture("drawTexture" + j, drawTextures[j]));
					}
				}
				var textureCount:int = 0;
				n = textureList.length;
				for (i = 0; i < n; i++) 
				{
					agalTex = textureList[i];
					if (agalTex.enabled == false)
					{
						continue;
					}
					
					textureResource = agalTex.getRenderTextureResource();
					//テクスチャがnullならダミーテクスチャを使う
					textureResource = (textureResource && textureResource.isUploaded && textureResource.isReady)? textureResource : dummyTexture;
					context.setTextureAt(textureCount, textureResource.texture);
					textureCount++;
				}
				
				//プログラム生成
				context.setBlendFactors(item.sourceFactor, item.destinationFactor);
				context.setCulling(item.culling);
				
				//行列用の定数を更新
				collector.vertexConstant.modelMatrix.matrix = item.matrix;
				collector.fragmentConstant.modelMatrix.matrix = item.matrix;
				
				//プログラム生成（キャッシュ判定で初回のみ生成）
				context.setProgram(item.shaderList.getProgram(collector));
				
				//定数をシェーダーに渡す
				var vertexIndex:int = collector.vertexCode.applyProgramConstants(context, 0);
				var fragmentIndex:int = collector.fragmentCode.applyProgramConstants(context, 0);
				
				//描画毎に処理を実行するタイプのシェーダーがあるなら
				if (item.shaderList.existTickShader)
				{
					item.shaderList.tick(frame, timer);
				}
				item.shaderList.vertexCode.applyProgramConstants(context, vertexIndex);
				item.shaderList.fragmentCode.applyProgramConstants(context, fragmentIndex);
				
				//描画
				context.drawTriangles(item.indexBuffer, item.firstIndex, item.numTriangles);
				
				//バッファをクリアする
				for (i = 0; i < 8; i++)
				{
					context.setVertexBufferAt(i, null);
					context.setTextureAt(i, null);
				}
				
				item = item.next;
			}
			
			context = null;
			agalTex = null;
			textureList = null;
			textureResource = null;
		}
		
		public function renderFilter(collector:RenderCollector, view:Viewport, sourceTextures:Array, targetTexture:RenderTextureResource, antiAlias:int):void 
		{
			renderTexture(sourceTextures, collector, view, false, targetTexture, view.backgroundColor, view.backgroundAlpha, antiAlias);
		}
		
	}

}