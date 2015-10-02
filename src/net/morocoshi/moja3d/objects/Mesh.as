package net.morocoshi.moja3d.objects 
{
	import net.morocoshi.moja3d.bounds.BoundingBox;
	import net.morocoshi.moja3d.config.LightSetting;
	import net.morocoshi.moja3d.materials.Material;
	import net.morocoshi.moja3d.materials.TriangleFace;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.renderer.RenderCollector;
	import net.morocoshi.moja3d.renderer.RenderElement;
	import net.morocoshi.moja3d.renderer.RenderLayer;
	import net.morocoshi.moja3d.renderer.RenderPhase;
	import net.morocoshi.moja3d.resources.Geometry;
	import net.morocoshi.moja3d.resources.Resource;
	import net.morocoshi.moja3d.shaders.render.ZBiasShader;
	import net.morocoshi.moja3d.shaders.ShaderList;
	
	use namespace moja3d;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class Mesh extends Object3D
	{
		public var layer:uint;
		public var surfaces:Vector.<Surface>;
		public var startShaderList:ShaderList;
		public var endShaderList:ShaderList;
		public var zBiasShader:ZBiasShader;
		private var _key:String;
		
		private var _zbias:Number;
		private var _renderable:Boolean;
		moja3d var _geometry:Geometry;
		private var renderElements:Vector.<RenderElement>;
		
		static moja3d var globalSeed:int;
		private var seed:String;
		
		public function Mesh() 
		{
			super();
			
			castShadow = LightSetting.defaultCastShadow;
			castLight = LightSetting.defaultCastLight;
			updateSeed();
			_zbias = 0;
			_renderable = true;
			layer = RenderLayer.OPAQUE;
			geometry = new Geometry();
			surfaces = new Vector.<Surface>;
			renderElements = new Vector.<RenderElement>;
			zBiasShader = new ZBiasShader(_zbias);
			startShaderList = null;
			endShaderList = null;
		}
		
		public function updateSeed():void
		{
			seed = String(++globalSeed);
		}
		
		public function get geometry():Geometry 
		{
			return _geometry;
		}
		
		public function set geometry(value:Geometry):void 
		{
			_geometry = value;
		}
		
		public function get zbias():Number 
		{
			return _zbias;
		}
		
		public function set zbias(value:Number):void 
		{
			zBiasShader.zbias = _zbias = value;
			zBiasShader.enabled = (_zbias != 0);
		}
		
		public function get renderable():Boolean 
		{
			return _renderable;
		}
		
		public function set renderable(value:Boolean):void 
		{
			_renderable = value;
		}
		
		/**
		 * ___ここをどうするか考える
		 */
		public function get key():String 
		{
			return seed + "_" + colorTransformShader.alphaMode;
		}
		
		override public function clone():Object3D 
		{
			var mesh:Mesh = new Mesh();
			cloneProperties(mesh);
			//子を再帰的にコピーする
			for (var current:Object3D = _children; current; current = current._next)
			{
				mesh.addChild(current.clone());
			}
			return mesh;
		}
		
		/**
		 * 現在の姿勢を考慮してバウンディング球を更新する。レンダリング時の処理に比べて重いので注意。
		 */
		public function updateBounds():void
		{
			boundingBox.transformByMatrix(worldMatrix, true);
		}
		
		/**
		 * 境界ボックスを包む境界球を計算するための下準備をする。
		 * この処理はジオメトリを生成した直後か、ジオメトリが変形した時に呼び出します。
		 * 全頂点を包む境界ボックスを求めるので負荷に注意。
		 */
		override public function calculateBounds():void 
		{
			if (boundingBox == null)
			{
				boundingBox = new BoundingBox();
			}
			
			var minX:Number = Number.MAX_VALUE;
			var minY:Number = Number.MAX_VALUE;
			var minZ:Number = Number.MAX_VALUE;
			var maxX:Number = -Number.MAX_VALUE;
			var maxY:Number = -Number.MAX_VALUE;
			var maxZ:Number = -Number.MAX_VALUE;
			
			var items:Vector.<Number> = geometry.verticesList[0];
			
			var i:int;
			var n:int = items.length;
			
			for (i = 0; i < n; i += 3)
			{
				var px:Number = items[i];
				var py:Number = items[i + 1];
				var pz:Number = items[i + 2];
				
				if (minX > px) minX = px;
				if (minY > py) minY = py;
				if (minZ > pz) minZ = pz;
				if (maxX < px) maxX = px;
				if (maxY < py) maxY = py;
				if (maxZ < pz) maxZ = pz;
			}
			boundingBox.minX = minX;
			boundingBox.minY = minY;
			boundingBox.minZ = minZ;
			boundingBox.maxX = maxX;
			boundingBox.maxY = maxY;
			boundingBox.maxZ = maxZ;
			
			boundingBox.localX = (minX + maxX) / 2;
			boundingBox.localY = (minY + maxY) / 2;
			boundingBox.localZ = (minZ + maxZ) / 2;
		}
		
		/**
		 * 全ポリゴンに指定のマテリアルを貼る。サーフェイスはリセットされて1つになる。
		 * @param	material
		 */
		public function setMaterialToAllSurfaces(material:Material):void
		{
			surfaces.length = 0;
			surfaces.push(new Surface(material, 0, _geometry.vertexIndices.length / 3));
		}
		
		/**
		 * Meshをコピーするが、GeometryとMaterialはインスタンスを共有する
		 * @return
		 */
		override public function reference():Object3D 
		{
			var mesh:Mesh = new Mesh();
			
			referenceProperties(mesh);
			
			//子を再帰的にコピーする
			for (var current:Object3D = _children; current; current = current._next)
			{
				mesh.addChild(current.reference());
			}
			
			return mesh;
		}
		
		override public function referenceProperties(target:Object3D):void
		{
			super.referenceProperties(target);
			
			var mesh:Mesh = target as Mesh;
			mesh.geometry = geometry;
			var n:int = surfaces.length;
			for (var i:int = 0; i < n; i++) 
			{
				var surface:Surface = new Surface(surfaces[i].material);
				surface.numTriangles = surfaces[i].numTriangles;
				surface.firstIndex = surfaces[i].firstIndex;
				mesh.surfaces.push(surface);
			}
		}
		
		override public function cloneProperties(target:Object3D):void 
		{
			super.cloneProperties(target);
			
			var mesh:Mesh = target as Mesh;
			mesh._zbias = _zbias;
			mesh.geometry = geometry.clone() as Geometry;
			var n:int = surfaces.length;
			for (var i:int = 0; i < n; i++) 
			{
				var surface:Surface = new Surface(surfaces[i].material);
				surface.numTriangles = surfaces[i].numTriangles;
				surface.firstIndex = surfaces[i].firstIndex;
				mesh.surfaces.push(surface);
			}
		}
		
		override public function dispose(hierarchy:Boolean):void
		{
			super.dispose(hierarchy);
			if (_geometry)
			{
				_geometry.dispose();
			}
			var n:int = surfaces.length;
			for (var i:int = 0; i < n; i++) 
			{
				if (surfaces[i].material)
				{
					surfaces[i].material.dispose();
				}
			}
		}
		
		override public function getResources(hierarchy:Boolean, filter:Class = null):Vector.<Resource> 
		{
			if (filter == null)
			{
				filter = Resource;
			}
			
			var result:Vector.<Resource> = super.getResources(hierarchy, filter);
			if (_geometry && (_geometry is filter))
			{
				result.push(_geometry);
			}
			
			var n:int = surfaces.length;
			for (var i:int = 0; i < n; i++) 
			{
				var material:Material = surfaces[i].material;
				if (material)
				{
					var resourceList:Vector.<Resource> = material.getResources();
					var numResource:int = resourceList.length;
					for (var j:int = 0; j < numResource; j++) 
					{
						var resource:Resource = resourceList[j];
						if (resource is filter)
						{
							result.push(resource);
						}
					}
				}
			}
			return result;
		}
		
		override moja3d function collectRenderElements(collector:RenderCollector, forceCalcMatrix:Boolean, forceCalcColor:Boolean, forceCalcBounds:Boolean, worldFlip:int, mask:uint):Boolean 
		{
			var success:Boolean = super.collectRenderElements(collector, forceCalcMatrix, forceCalcColor, forceCalcBounds, worldFlip, mask);
			if (success == false || _geometry.isUploaded == false)
			{
				return false;
			}
			
			if (_renderable == false) return true;
			
			mask |= renderMask;
			var count:int = -1;
			var n:int = surfaces.length;
			for (var i:int = 0; i < n; i++) 
			{
				var surface:Surface = surfaces[i];
				var material:Material = surface.material;
				if (material == null) continue;
				
				material.collectShaderList(collector, this);
				if (collector.renderPhase == RenderPhase.REFLECT && material.shaderList.reflectShader)
				{
					return false;
				}
				
				//反射要素チェックフェーズの場合に反射や影などのシェーダーをチェックする。レンダリング要素はマスク以外追加しないで終了
				var checkMode:Boolean = (collector.renderPhase == RenderPhase.CHECK);
				if (checkMode)
				{
					//反射要素があれば収集するが、カメラが無い＝preloadPrograms時はスキップする
					var checkShader:ShaderList = collector.opaquePassShaderList || collector.alphaPassShaderList;
					if (checkShader && checkShader.reflectShader)
					{
						if (collector.camera)
						{
							collector.addReflectElement(_worldMatrix.position.z, checkShader.reflectShader);
						}
						else
						{
							collector.reflectiveWater.hasReflectElement = true;
						}
					}
					var hasShadow1:Boolean = (material.shaderList.shadowShader && material.shaderList.shadowShader.enabled);
					var hasShadow2:Boolean = (startShaderList && startShaderList.shadowShader && startShaderList.shadowShader.enabled);
					var hasShadow3:Boolean = (endShaderList && endShaderList.shadowShader && endShaderList.shadowShader.enabled);
					if (hasShadow1 || hasShadow2 || hasShadow3)
					{
						collector.hasShadowElement = true;
					}
					if (material.shaderList.lightShader)
					{
						collector.hasLightElement = true;
					}
					//マスクがあれば追加する
					if (mask)
					{
						collector.hasMaskElement = true;
						material.getMaskShaderList(collector, this, mask);
					}
					else
					{
						continue;
					}
				}
				
				for (var j:int = 0; j < 2; j++) 
				{
					var shaderList:ShaderList = (j == 0)? collector.opaquePassShaderList : collector.alphaPassShaderList;
					if (shaderList == null) continue;
					
					count++;
					var shaderLayer:uint = (j == 0)? RenderLayer.OPAQUE : RenderLayer.TRANSPARENT;
					var element:RenderElement = (renderElements.length > count)? renderElements[count] : null;
					if (element == null)
					{
						element = renderElements[count] = new RenderElement();
					}
					element.name = String(this) + _geometry.indexBuffer;
					element.firstIndex = surface.firstIndex;
					element.numTriangles = surface.numTriangles;
					element.matrix = _worldMatrix;
					element.vertexBufferFormatList = _geometry.vertexBufferFormatList;
					element.vertexBufferList = _geometry.vertexBufferList;
					element.indexBuffer = _geometry.indexBuffer;
					element.culling = material.culling;
					element.sourceFactor = material.sourceFactor;
					element.destinationFactor = material.destinationFactor;
					//マイナススケールでフリップしていた場合は表示を反転する
					if (worldFlip * flip == -1)
					{
						if (element.culling == TriangleFace.FRONT) element.culling = TriangleFace.BACK;
						else if (element.culling == TriangleFace.BACK) element.culling = TriangleFace.FRONT;
					}
					element.shaderList = shaderList;
					element.layer = layer | surface.layer | shaderLayer;
					element.sortPriority = sortPriority;
					
					collector.addRenderElement(element);
				}
				
			}
			
			return true;
		}
		
	}

}