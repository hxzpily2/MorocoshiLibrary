package net.morocoshi.moja3d.renderer 
{
	import flash.display3D.Context3D;
	import net.morocoshi.moja3d.resources.RenderTextureResource;
	import net.morocoshi.moja3d.resources.TextureResource;
	import net.morocoshi.moja3d.shaders.filters.BasicFilterShader;
	import net.morocoshi.moja3d.shaders.filters.EndFilterShader;
	import net.morocoshi.moja3d.shaders.ShaderList;
	import net.morocoshi.moja3d.view.Scene3D;
	
	/**
	 * ポストエフェクト用の各種テクスチャを管理
	 * @author tencho
	 */
	public class PostEffectManager 
	{
		public var scene:Scene3D;
		public var antiAlias:int;
		public var renderer:Renderer;
		public var collector:RenderCollector;
		public var renderTexture:RenderTextureResource;
		public var processTexture1:RenderTextureResource;
		public var processTexture2:RenderTextureResource;
		public var maskTexture:RenderTextureResource;
		public var currentTexture:RenderTextureResource;
		private var isEnd:Boolean;
		public var captureShader:ShaderList;
		private var processTextures:Array;
		
		/**
		 * 
		 */
		public function PostEffectManager() 
		{
			antiAlias = 0;
			renderTexture = new RenderTextureResource(1024, 1024, 0);
			renderTexture.name = "renderTexture";
			maskTexture = new RenderTextureResource(1024, 1024, 2);
			maskTexture.name = "maskTexture";
			processTextures = [];
			processTexture1 = new RenderTextureResource(1024, 1024, 3);
			processTexture1.name = "processTexture1";
			processTexture2 = new RenderTextureResource(1024, 1024, 3);
			processTexture2.name = "processTexture2";
			captureShader = new ShaderList();
			captureShader.addShader(new BasicFilterShader());
			captureShader.addShader(new EndFilterShader());
		}
		
		/**
		 * Scene3Dからの呼び出し。色々初期化。
		 */
		public function start():void
		{
			currentTexture = null;
			isEnd = false;
			getNextTexture(0);
		}
		
		/**
		 * Scene3Dからの呼び出し。最後のFilter3Dの直前に。
		 */
		public function end():void 
		{
			isEnd = true;
		}
		
		/**
		 * 
		 * @param	context3D
		 * @param	w
		 * @param	h
		 */
		public function setViewSize(context3D:Context3D, w:int, h:int):void
		{
			renderTexture.createTexture(context3D, w, h);
			maskTexture.createTexture(context3D, w, h);
			processTexture1.createTexture(context3D, w, h);
			processTexture2.createTexture(context3D, w, h);
		}
		
		/**
		 * 
		 * @param	shaderList
		 * @param	textures
		 */
		public function renderFinal(shaderList:ShaderList, lowLV:int = 0, textures:Array = null):void
		{
			collector.collectFilter(shaderList);
			var source:Array = textures || [currentTexture];
			var n:int = source.length;
			for (var i:int = 0; i < n; i++) 
			{
				if (source[i] == null) source[i] = currentTexture;
			}
			var target:RenderTextureResource = isEnd? null : getNextTexture(lowLV);
			renderer.renderFilter(collector, source, target, antiAlias);
		}
		
		/**
		 * 
		 * @param	shaderList
		 * @param	textures
		 * @param	destination
		 * @return
		 */
		public function renderProcess(shaderList:ShaderList, lowLV:int = 0, textures:Array = null, destination:RenderTextureResource = null):RenderTextureResource 
		{
			collector.collectFilter(shaderList);
			var source:Array = textures || [currentTexture];
			var n:int = source.length;
			for (var i:int = 0; i < n; i++) 
			{
				if (source[i] == null) source[i] = currentTexture;
			}
			var target:RenderTextureResource = destination || getNextTexture(lowLV);
			renderer.renderFilter(collector, source, target, antiAlias);
			currentTexture = target;
			return currentTexture;
		}
		
		private function getNextTexture(lowLV:int):RenderTextureResource 
		{
			if (currentTexture == null)
			{
				currentTexture = renderTexture;
			}
			else if (currentTexture == renderTexture)
			{
				currentTexture = processTexture1;
			}
			else if (currentTexture == processTexture1)
			{
				currentTexture = processTexture2;
			}
			else
			{
				currentTexture = processTexture1;
			}
			return currentTexture;
		}
		
		/**
		 * 現在処理中の最新のテクスチャをレンダリングする（デバッグ用）
		 */
		public function capture(texture:TextureResource = null):void 
		{
			renderFinal(captureShader, 0, texture? [texture] : null);
		}
		
	}

}