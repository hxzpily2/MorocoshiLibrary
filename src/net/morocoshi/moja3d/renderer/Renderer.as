package net.morocoshi.moja3d.renderer 
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DCompareMode;
	import flash.geom.Matrix3D;
	import flash.utils.getTimer;
	import net.morocoshi.moja3d.agal.AGALTexture;
	import net.morocoshi.moja3d.events.Event3D;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.objects.Camera3D;
	import net.morocoshi.moja3d.objects.Shadow;
	import net.morocoshi.moja3d.resources.RenderTextureResource;
	import net.morocoshi.moja3d.resources.TextureResource;
	import net.morocoshi.moja3d.view.Scene3D;
	
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
		
		public function renderTexture(textures:Array, collector:RenderCollector, target:RenderTextureResource, rgb:uint, alpha:Number, antiAlias:int):void
		{
			renderScene(collector, null, target, textures, rgb, alpha, antiAlias);
		}
		
		public function renderShadowMap(collector:RenderCollector, shadow:Shadow):void 
		{
			//@@@アンチエイリアスは1固定で大丈夫？
			shadow.readyShadowTexture(collector.context3D);
			renderScene(collector, shadow, shadow.shadowTexture, null, 0xffffff, 1, 1);
		}
		
		public function renderLightMap(collector:RenderCollector, shadow:Shadow):void 
		{
			//@@@アンチエイリアスは1固定で大丈夫？
			shadow.readyLightTexture(collector.context3D);
			renderScene(collector, shadow, shadow.lightTexture, null, 0xffffff, 1, 1);
		}
		
		private var lastTarget:RenderTextureResource = new RenderTextureResource();
		/**
		 * 
		 * @param	collector	事前に収集しておいたメッシュとか
		 * @param	camera	カメラ
		 * @param	target	テクスチャに描画したい場合に使う
		 * @param	drawTexture	主にフィルターに使う素材用テクスチャリスト
		 * @param	rgb	背景色
		 * @param	alpha	背景アルファ
		 */
		public function renderScene(collector:RenderCollector, camera:Camera3D, target:RenderTextureResource, drawTextures:Array, rgb:uint, alpha:Number, antiAlias:int):void
		{
			var context3D:Context3D = collector.context3D;
			
			frame++;
			if (camera)
			{
				camera.checkPerspectiveUpdate();
				collector.vertexConstant.clipping.x = camera.zNear;
				collector.vertexConstant.clipping.y = camera.zFar;
				collector.vertexConstant.clipping.z = camera.zFar - camera.zNear;
				collector.fragmentConstant.clipping.x = camera.zNear;
				collector.fragmentConstant.clipping.y = camera.zFar;
				collector.fragmentConstant.clipping.z = camera.zFar - camera.zNear;
				
				//各種行列
				collector.vertexConstant.viewMatrix.matrix = camera.viewMatrix;
				collector.vertexConstant.projMatrix.matrix = camera.perspectiveMatrix;
				collector.fragmentConstant.viewMatrix.matrix = camera.viewMatrix;
				collector.fragmentConstant.projMatrix.matrix = camera.perspectiveMatrix;
				
				//カメラのワールド座標
				var cameraMatrix:Matrix3D = camera.worldMatrix;
				collector.vertexConstant.cameraPosition.x = cameraMatrix.rawData[12];
				collector.vertexConstant.cameraPosition.y = cameraMatrix.rawData[13];
				collector.vertexConstant.cameraPosition.z = cameraMatrix.rawData[14];
				collector.fragmentConstant.cameraPosition.x = cameraMatrix.rawData[12];
				collector.fragmentConstant.cameraPosition.y = cameraMatrix.rawData[13];
				collector.fragmentConstant.cameraPosition.z = cameraMatrix.rawData[14];
			}
			
			collector.vertexConstant.viewSize.x = scene.view.width;
			collector.vertexConstant.viewSize.y = scene.view.height;
			collector.fragmentConstant.viewSize.x = scene.view.width;
			collector.fragmentConstant.viewSize.y = scene.view.height;
			
			//targetが指定されていればテクスチャにレンダリング
			if (lastTarget != target)
			{
				lastTarget = target;
				if (target)
				{
					context3D.setRenderToTexture(target.texture, true, antiAlias);
					target.isUploaded = true;
				}
				else
				{
					context3D.setRenderToBackBuffer();
				}
				
			}
			
			//context3D.setScissorRectangle(new Rectangle(0, 0, scene.view.width, scene.view.height));
			
			//背景色でクリア
			var r:Number = (rgb >> 16 & 0xff) / 0xff;
			var g:Number = (rgb >> 8 & 0xff) / 0xff;
			var b:Number = (rgb & 0xff) / 0xff;
			context3D.clear(r, g, b, alpha);
			
			if (target == null)
			{
				scene.dispatchEvent(new Event3D(Event3D.CONTEXT_POST_CLEAR));
			}
			
			//最背面要素のレンダリング
			if (collector.renderElementList[RenderLayer.BACKGROUND])
			{
				context3D.setDepthTest(false, Context3DCompareMode.ALWAYS);
				renderLayer(RenderLayer.BACKGROUND, collector, camera, drawTextures);
			}
			
			//不透明要素のレンダリング
			if (collector.renderElementList[RenderLayer.OPAQUE])
			{
				context3D.setDepthTest(true, Context3DCompareMode.LESS);
				renderLayer(RenderLayer.OPAQUE, collector, camera, drawTextures);
			}
			
			//半透明要素のレンダリング
			if (collector.renderElementList[RenderLayer.TRANSPARENT])
			{
				context3D.setDepthTest(true, Context3DCompareMode.LESS);
				sortItem(RenderLayer.TRANSPARENT, collector, camera);//カメラからの距離でソート
				renderLayer(RenderLayer.TRANSPARENT, collector, camera, drawTextures);
			}
			
			//最前面要素のレンダリング
			if (collector.renderElementList[RenderLayer.FOREFRONT])
			{
				context3D.setDepthTest(false, Context3DCompareMode.ALWAYS);
				renderLayer(RenderLayer.FOREFRONT, collector, camera, drawTextures);
			}
			
			//2Dオーバーレイのレンダリング
			if (collector.renderElementList[RenderLayer.OVERLAY])
			{
				context3D.setDepthTest(false, Context3DCompareMode.ALWAYS);
				renderLayer(RenderLayer.OVERLAY, collector, camera, drawTextures);
			}
			
		}
		
		/**
		 * RenderElementをカメラ平面からの距離でソートする
		 * @param	layer
		 * @param	collector
		 * @param	camera
		 */
		public function sortItem(layer:int, collector:RenderCollector, camera:Camera3D):void
		{
			var context3D:Context3D = collector.context3D;
			
			var item:RenderElement = collector.renderElementList[layer];
			while (item)
			{
				//カメラ平面からの距離をチェックする
				var data:Vector.<Number> = item.matrix.rawData;
				item.distance = camera.getDistance(data[12], data[13], data[14]) - item.sortPriority;
				item = item.next;
			}
			collector.renderElementList[layer] = elementSort.sort(collector.renderElementList[layer]);
		}
		
		/**
		 * 
		 * @param	layer
		 * @param	collector
		 * @param	camera
		 * @param	drawTexture	フィルター用？
		 */
		public function renderLayer(layer:int, collector:RenderCollector, camera:Camera3D, drawTextures:Array):void
		{
			var context3D:Context3D = collector.context3D;
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
					context3D.setVertexBufferAt(i, item.vertexBufferList[i], 0, item.vertexBufferFormatList[i]);
				}
				
				//テクスチャ
				var textureList:Vector.<AGALTexture> = collector.fragmentCode.textureList.concat(item.shaderList.fragmentCode.textureList);
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
					var agalTex:AGALTexture = textureList[i];
					if (agalTex.enabled == false)
					{
						continue;
					}
					
					var textureResource:TextureResource = agalTex.texture;
					//テクスチャがnullならダミーテクスチャを使う
					textureResource = (textureResource && textureResource.isUploaded && textureResource.isReady)? textureResource : dummyTexture;
					context3D.setTextureAt(textureCount, textureResource.texture);
					textureCount++;
				}
				
				//プログラム生成
				context3D.setBlendFactors(item.sourceFactor, item.destinationFactor);
				context3D.setCulling(item.culling);
				
				//行列用の定数を更新
				collector.vertexConstant.modelMatrix.matrix = item.matrix;
				collector.fragmentConstant.modelMatrix.matrix = item.matrix;
				
				//プログラム生成（キャッシュ判定で初回のみ生成）
				context3D.setProgram(item.shaderList.getProgram(collector));
				
				//定数をシェーダーに渡す
				var vertexIndex:int = collector.vertexCode.applyProgramConstants(context3D, 0);
				var fragmentIndex:int = collector.fragmentCode.applyProgramConstants(context3D, 0);
				
				item.shaderList.tick(frame, timer);
				item.shaderList.vertexCode.applyProgramConstants(context3D, vertexIndex);
				item.shaderList.fragmentCode.applyProgramConstants(context3D, fragmentIndex);
				
				//描画
				context3D.drawTriangles(item.indexBuffer, item.firstIndex, item.numTriangles);
				
				//バッファをクリアする
				for (i = 0; i < 8; i++)
				{
					context3D.setVertexBufferAt(i, null);
					context3D.setTextureAt(i, null);
				}
				
				item = item.next;
			}
		}
		
		public function renderFilter(collector:RenderCollector, sourceTextures:Array, targetTexture:RenderTextureResource, antiAlias:int):void 
		{
			renderTexture(sourceTextures, collector, targetTexture, 0x000000, 1, antiAlias);
		}
		
	}

}