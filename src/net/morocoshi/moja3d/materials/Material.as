package net.morocoshi.moja3d.materials 
{
	import flash.display.BlendMode;
	import flash.display3D.Context3DBlendFactor;
	import net.morocoshi.common.math.list.VectorUtil;
	import net.morocoshi.moja3d.agal.AGALCache;
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.agal.AGALTexture;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.objects.Mesh;
	import net.morocoshi.moja3d.overlay.objects.Sprite2D;
	import net.morocoshi.moja3d.renderer.RenderCollector;
	import net.morocoshi.moja3d.renderer.RenderPhase;
	import net.morocoshi.moja3d.resources.Geometry;
	import net.morocoshi.moja3d.resources.Resource;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.core.BasicShader;
	import net.morocoshi.moja3d.shaders.core.EndShader;
	import net.morocoshi.moja3d.shaders.depth.DepthEndShader;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	import net.morocoshi.moja3d.shaders.ShaderList;
	
	use namespace moja3d;
	
	/**
	 * マテリアル
	 * 
	 * @author tencho
	 */
	public class Material
	{
		public var name:String;
		/**裏表が本来と逆になっているので注意。TriangleFaceクラス参照*/
		public var culling:String;
		/**シェーダーリスト*/
		public var shaderList:ShaderList;
		/**反射レンダリング時のシェーダー*/
		public var reflectShaderList:ShaderList;
		
		public var sourceFactor:String;
		public var destinationFactor:String;
		
		private var _alphaPassEnabled:Boolean;
		private var _opaquePassEnabled:Boolean;
		private var _alphaThreshold:Number;
		private var _shadowThreshold:Number;
		private var depthEndShader:DepthEndShader;
		
		moja3d var opaquePassConst:AGALConstant;
		moja3d var alphaPassConst:AGALConstant;
		
		static moja3d var globalSeed:int;
		moja3d var seed:String;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function Material() 
		{
			name = "";
			seed = String(++globalSeed);
			culling = TriangleFace.FRONT;
			shaderList = new ShaderList();
			_alphaPassEnabled = true;
			_opaquePassEnabled = true;
			_alphaThreshold = 0.99;
			_shadowThreshold = 0.9;
			depthEndShader = new DepthEndShader(_shadowThreshold);
			blendMode = BlendMode.NORMAL;
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		public function get blendMode():String
		{
			if (sourceFactor == Context3DBlendFactor.SOURCE_ALPHA && destinationFactor == Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA) return BlendMode.NORMAL;
			if (sourceFactor == Context3DBlendFactor.ONE && destinationFactor == Context3DBlendFactor.ONE) return BlendMode.ADD;
			if (sourceFactor == Context3DBlendFactor.DESTINATION_COLOR && destinationFactor == Context3DBlendFactor.ZERO) return BlendMode.MULTIPLY;
			if (sourceFactor == Context3DBlendFactor.ONE && destinationFactor == Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR) return BlendMode.SCREEN;
			return null;
		}
		
		public function set blendMode(value:String):void
		{
			switch(value)
			{
				case BlendMode.ADD:
					sourceFactor = Context3DBlendFactor.ONE;
					destinationFactor = Context3DBlendFactor.ONE;
					break;
				case BlendMode.MULTIPLY:
					sourceFactor = Context3DBlendFactor.DESTINATION_COLOR;
					destinationFactor = Context3DBlendFactor.ZERO;
					break;
				case BlendMode.SCREEN:
					sourceFactor = Context3DBlendFactor.ONE;
					destinationFactor = Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR;
					break;
				case BlendMode.NORMAL:
					sourceFactor = Context3DBlendFactor.SOURCE_ALPHA;
					destinationFactor = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
					break;
				default:
					sourceFactor = Context3DBlendFactor.SOURCE_ALPHA;
					destinationFactor = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			}
		}
		
		/**
		 * 全シェーダーが使用しているリソースを収集。シェーダーリストをループしてチェックする
		 * @param	context3D
		 */
		public function getResources():Vector.<Resource> 
		{
			var result:Vector.<Resource> = new Vector.<Resource>;
			
			var textureList:Vector.<AGALTexture> = new Vector.<AGALTexture>;
			VectorUtil.attachListDiff(textureList, shaderList.vertexCode.textureList);
			VectorUtil.attachListDiff(textureList, shaderList.fragmentCode.textureList);
			if (reflectShaderList)
			{
				VectorUtil.attachListDiff(textureList, reflectShaderList.vertexCode.textureList);
				VectorUtil.attachListDiff(textureList, reflectShaderList.fragmentCode.textureList);
			}
			
			var n:int = textureList.length;
			for (var i:int = 0; i < n; i++) 
			{
				var texture:AGALTexture = textureList[i];
				if (texture.texture)
				{
					result.push(texture.texture);
				}
			}
			
			return result;
		}
		
		public function dispose():void 
		{
			for each(var resource:Resource in getResources())
			{
				if (resource.autoDispose)
				{
					resource.dispose();
				}
			}
		}
		
		/**
		 * Sprite2D用のShaderListを取得
		 * @param	collector
		 * @param	sprite
		 */
		moja3d function getSpriteShaderList(collector:RenderCollector, sprite:Sprite2D):ShaderList
		{
			var phase:String = collector.renderPhase;
			var key:String = seed + "/" + sprite.seed + "/" + phase;
			
			var renderShader:ShaderList = AGALCache.shader[key];
			if (renderShader == null)
			{
				renderShader = AGALCache.shader[key] = new ShaderList();
				renderShader.addShader(AGALCache.spriteStartShaderList);
				if (sprite.startShaderList)
				{
					renderShader.attach(sprite.startShaderList);
				}
				renderShader.attach(shaderList);
				if (sprite.endShaderList)
				{
					renderShader.attach(sprite.endShaderList);
				}
				renderShader.addShader(AGALCache.spriteEndShaderList);
				renderShader.updateConstantList();
			}
			
			return renderShader;
		}
		
		/**
		 * レンダリングに必要なシェーダーリストを収集。描画要素の収集過程で呼び出される。
		 * @param	collector
		 * @param	mesh
		 */
		moja3d function collectShaderList(collector:RenderCollector, mesh:Mesh, geometry:Geometry, skinShader:MaterialShader):void 
		{
			collector.opaquePassShaderList = null;
			collector.alphaPassShaderList = null;
			
			var shaderData:Object;
			var mode:uint;
			
			var phase:String = collector.renderPhase;
			var colorKey:String = collector.useObjectColorTransform? "c" : "C";
			var skinKey:String = skinShader? skinShader.getKey() : "none";
			
			//通常レンダリング用
			if (phase != RenderPhase.REFLECT)
			{
				var normalKey:String = seed + "/" + skinKey + "/" + shaderList.key + "/" + colorKey + mesh.key + "/normal";
				shaderData = AGALCache.shader[normalKey];
				if (shaderData == null)
				{
					shaderData = { };
					var renderShader:ShaderList = new ShaderList();
					renderShader.name = mesh.name;
					renderShader.addShader(new BasicShader(geometry));
					if (mesh.startShaderList) renderShader.attach(mesh.startShaderList);
					if (skinShader) renderShader.addShader(skinShader);
					renderShader.attach(shaderList, geometry);
					if (mesh.endShaderList) renderShader.attach(mesh.endShaderList);
					renderShader.addShader(AGALCache.viewShaderList);
					if (mesh.afterViewShaderList) renderShader.attach(mesh.afterViewShaderList);
					if (mesh.zbias != 0) renderShader.addShader(mesh.zBiasShader);
					if (collector.useObjectColorTransform) renderShader.addShader(mesh.colorTransformShader);
					renderShader.addShader(new EndShader(geometry));
					
					renderShader.updateFromGeometry(geometry);
					/*
					var removed:Vector.<MaterialShader> = 
					if (removed.length > 0)
					{
						シェーダーに無効化されたものがあった場合
						shaderList.removeShaders(removed);
						normalKey = seed + "/" + shaderList.key + "/" + colorKey + mesh.seed + "/normal";
					}
					*/
					AGALCache.shader[normalKey] = shaderData;
					
					mode = renderShader.alphaMode;
					alphaPassConst = null;
					opaquePassConst = null;
					shaderData.opaque = (mode == AlphaMode.NONE)? renderShader : (mode == AlphaMode.MIX)? renderShader.cloneWithOpaque(this) : null;
					shaderData.alpha = (mode == AlphaMode.ALL)? renderShader : (mode == AlphaMode.MIX)? renderShader.cloneWithAlpha(this) : null;
				}
			}
			
			//デプスマップ用
			if (phase == RenderPhase.DEPTH || phase == RenderPhase.LIGHT)
			{
				var depthKey:String = seed + "/" + skinKey + "/" + shaderList.key + "/" + colorKey + mesh.key + "/depth";
				shaderData = AGALCache.shader[depthKey];
				if (shaderData == null)
				{
					shaderData = { };
					var renderKey:String = seed + "/" + skinKey + "/" + shaderList.key + "/" + colorKey + mesh.key + "/normal";
					var renderData:Object = AGALCache.shader[renderKey];
					if (renderData.opaque)
					{
						var depthOpaqueShader:ShaderList = new ShaderList();
						depthOpaqueShader.attachExtra(renderData.opaque, phase);
						depthOpaqueShader.addShader(depthEndShader);
						shaderData.opaque = depthOpaqueShader;
					}
					if (renderData.alpha)
					{
						var depthAlphaShader:ShaderList = new ShaderList();
						depthAlphaShader.attachExtra(renderData.alpha, phase);
						depthAlphaShader.addShader(depthEndShader);
						shaderData.alpha = depthAlphaShader;
					}
					
					AGALCache.shader[depthKey] = shaderData;
				}
			}
			
			//鏡面反射用
			if (phase == RenderPhase.REFLECT)
			{
				var reflectKey:String = seed + "/" + skinKey + "/" + shaderList.key + "/" + colorKey + mesh.key + "/reflect";
				shaderData = AGALCache.shader[reflectKey];
				if (shaderData == null)
				{
					shaderData = { };
					
					var reflectShader:ShaderList = new ShaderList();
					reflectShader.addShader(new BasicShader(geometry));
					reflectShader.addShader(collector.reflectiveWater.killShader);
					if (mesh.startShaderList) reflectShader.attachExtra(mesh.startShaderList, phase);
					if (skinShader) reflectShader.addShader(skinShader);
					reflectShader.attach(reflectShaderList || shaderList);
					if (mesh.endShaderList) reflectShader.attachExtra(mesh.endShaderList, phase);
					reflectShader.addShader(AGALCache.viewShaderList);
					if (mesh.afterViewShaderList) reflectShader.attach(mesh.afterViewShaderList);
					if (mesh.zbias != 0) reflectShader.addShader(mesh.zBiasShader);
					if (collector.useObjectColorTransform) reflectShader.addShader(mesh.colorTransformShader);
					reflectShader.addShader(new EndShader(geometry));
					
					AGALCache.shader[reflectKey] = shaderData;
					
					mode = reflectShader.alphaMode;
					alphaPassConst = null;
					opaquePassConst = null;
					shaderData.opaque = (mode == AlphaMode.NONE)? reflectShader : (mode == AlphaMode.MIX)? reflectShader.cloneWithOpaque(this) : null;
					shaderData.alpha = (mode == AlphaMode.ALL)? reflectShader : (mode == AlphaMode.MIX)? reflectShader.cloneWithAlpha(this) : null;
				}
			}
			
			collector.opaquePassShaderList = (_opaquePassEnabled && shaderData)? shaderData.opaque : null;
			collector.alphaPassShaderList = (_alphaPassEnabled && shaderData)? shaderData.alpha : null;
		}
		
		public function getMaskShaderList(collector:RenderCollector, mesh:Mesh, geometry:Geometry, mask:uint, skinShader:MaterialShader):void
		{
			var skinKey:String = skinShader? skinShader.getKey() : "none";
			var maskKey:String = seed + "/" + skinKey + "/" + mesh.key + "/mask";
			
			collector.opaquePassShaderList = null;
			collector.alphaPassShaderList = null;
			
			//var result:ShaderList = AGALCache.shader[key];
			var shaderData:Object = AGALCache.shader[maskKey];
			if (shaderData == null)
			{
				shaderData = { };
				AGALCache.shader[maskKey] = shaderData;
				var result:ShaderList = new ShaderList();
				result.addShader(new BasicShader(geometry));
				if (mesh.startShaderList) result.attachExtra(mesh.startShaderList, RenderPhase.MASK);
				if (skinShader) result.addShader(skinShader);
				result.attach(collector.getMaskShaderList(mask));
				result.attachExtra(shaderList, RenderPhase.MASK);
				if (mesh.endShaderList) result.attachExtra(mesh.endShaderList, RenderPhase.MASK);
				result.addShader(AGALCache.viewShaderList);
				if (mesh.afterViewShaderList) result.attach(mesh.afterViewShaderList);
				result.addShader(new EndShader(geometry));
				//___ここは？
				result.updateFromGeometry(geometry);
				
				var mode:uint = result.alphaMode;
				shaderData.opaque = (mode == AlphaMode.NONE)? result : (mode == AlphaMode.MIX)? result.cloneWithOpaque(this) : null;
				shaderData.alpha = (mode == AlphaMode.ALL)? result : (mode == AlphaMode.MIX)? result.cloneWithAlpha(this) : null;
			}
			//collector.opaquePassShaderList = result.cloneWithOpaque(this);
			collector.opaquePassShaderList = (_opaquePassEnabled && shaderData)? shaderData.opaque : null;
			collector.alphaPassShaderList = (_alphaPassEnabled && shaderData)? shaderData.alpha : null;
		}
		
		/**
		 * 参照
		 */
		public function reference():Material
		{
			var result:Material = new Material();
			result.name = name;
			result.culling = culling;
			result.shadowThreshold = shadowThreshold;
			result.shaderList = shaderList.reference();
			result.reflectShaderList = reflectShaderList? reflectShaderList.reference() : null;
			return result;
		}
		
		/**
		 * 複製
		 */
		public function clone():Material
		{
			var result:Material = new Material();
			result.name = name;
			result.culling = culling;
			result.shadowThreshold = shadowThreshold;
			result.shaderList = shaderList.clone();
			result.reflectShaderList = reflectShaderList? reflectShaderList.clone() : null;
			return result;
		}
		
		public function get shadowThreshold():Number 
		{
			return _shadowThreshold;
		}
		
		public function set shadowThreshold(value:Number):void 
		{
			_shadowThreshold = value;
			depthEndShader.shadowThreshold = _shadowThreshold;
		}
		
		public function get alphaThreshold():Number 
		{
			return _alphaThreshold;
		}
		
		public function set alphaThreshold(value:Number):void 
		{
			_alphaThreshold = value;
			if (alphaPassConst) alphaPassConst.x = _alphaThreshold;
			if (opaquePassConst) opaquePassConst.x = _alphaThreshold;
		}
		
		/**
		 * 半透明部分をレンダリングするかどうか
		 */
		public function get alphaPassEnabled():Boolean 
		{
			return _alphaPassEnabled;
		}
		
		public function set alphaPassEnabled(value:Boolean):void 
		{
			_alphaPassEnabled = value;
		}
		
		/**
		 * 不透明部分をレンダリングするかどうか
		 */
		public function get opaquePassEnabled():Boolean 
		{
			return _opaquePassEnabled;
		}
		
		public function set opaquePassEnabled(value:Boolean):void 
		{
			_opaquePassEnabled = value;
		}
		
	}

}