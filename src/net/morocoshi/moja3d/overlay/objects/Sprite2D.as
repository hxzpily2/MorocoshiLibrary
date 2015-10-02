package net.morocoshi.moja3d.overlay.objects 
{
	import net.morocoshi.moja3d.materials.Material;
	import net.morocoshi.moja3d.materials.TriangleFace;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.objects.Surface;
	import net.morocoshi.moja3d.renderer.RenderCollector;
	import net.morocoshi.moja3d.renderer.RenderElement;
	import net.morocoshi.moja3d.renderer.RenderLayer;
	import net.morocoshi.moja3d.resources.Geometry;
	import net.morocoshi.moja3d.resources.Resource;
	import net.morocoshi.moja3d.shaders.ShaderList;
	
	use namespace moja3d;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class Sprite2D extends Object2D 
	{
		public var surfaces:Vector.<Surface>;
		public var startShaderList:ShaderList;
		public var endShaderList:ShaderList;
		moja3d var _geometry:Geometry;
		private var renderElements:Vector.<RenderElement>;
		
		static moja3d var globalSeed:int;
		moja3d var seed:String;
		
		public function Sprite2D() 
		{
			super();
			seed = "";
			_geometry = null;
			surfaces = new Vector.<Surface>;
			renderElements = new Vector.<RenderElement>;
			startShaderList = null;
			endShaderList = new ShaderList([colorTransformShader]);
		}
		
		public function get geometry():Geometry 
		{
			return _geometry;
		}
		
		public function set geometry(value:Geometry):void 
		{
			_geometry = value;
		}
		
		override public function clone():Object2D 
		{
			var sprite:Sprite2D = new Sprite2D();
			cloneProperties(sprite);
			//子を再帰的にコピーする
			for (var current:Object2D = _children; current; current = current._next)
			{
				sprite.addChild(current.clone());
			}
			return sprite;
		}
		
		public function setMaterialToAllSurfaces(material:Material):void
		{
			surfaces.length = 0;
			surfaces.push(new Surface(material, 0, _geometry.vertexIndices.length / 3));
		}
		
		/**
		 * Meshをコピーするが、GeometryとMaterialはインスタンスを共有する
		 * @return
		 */
		override public function reference():Object2D 
		{
			var sprite:Sprite2D = new Sprite2D();
			
			referenceProperties(sprite);
			
			//子を再帰的にコピーする
			for (var current:Object2D = _children; current; current = current._next)
			{
				sprite.addChild(current.reference());
			}
			
			return sprite;
		}
		
		override public function referenceProperties(target:Object2D):void
		{
			super.referenceProperties(target);
			
			var sprite:Sprite2D = target as Sprite2D;
			sprite.geometry = geometry;
			var n:int = surfaces.length;
			for (var i:int = 0; i < n; i++) 
			{
				var surface:Surface = new Surface(surfaces[i].material);
				surface.numTriangles = surfaces[i].numTriangles;
				surface.firstIndex = surfaces[i].firstIndex;
				sprite.surfaces.push(surface);
			}
		}
		
		override public function cloneProperties(target:Object2D):void 
		{
			super.cloneProperties(target);
			
			var sprite:Sprite2D = target as Sprite2D;
			sprite.geometry = geometry.clone() as Geometry;
			var n:int = surfaces.length;
			for (var i:int = 0; i < n; i++) 
			{
				var surface:Surface = new Surface(surfaces[i].material);
				surface.numTriangles = surfaces[i].numTriangles;
				surface.firstIndex = surfaces[i].firstIndex;
				sprite.surfaces.push(surface);
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
		
		override public function getResources(hierarchy:Boolean, classObject:Class = null):Vector.<Resource> 
		{
			var result:Vector.<Resource> = super.getResources(hierarchy, classObject);
			
			if (_geometry && (classObject == null || _geometry is classObject))
			{
				result.push(_geometry);
			}
			
			var n:int = surfaces.length;
			for (var i:int = 0; i < n; i++) 
			{
				var material:Material = surfaces[i].material;
				if (material)
				{
					var resources:Vector.<Resource> = material.getResources();
					var numResouces:int = resources.length;
					for (var j:int = 0; j < numResouces; j++)
					{
						var resource:Resource = resources[j];
						if (classObject == null || resource is classObject)
						{
							result.push(resource);
						}
					}
				}
			}
			return result;
		}
		
		override moja3d function collectRenderElements(collector:RenderCollector, forceCalcMatrix:Boolean, forceCalcColor:Boolean, worldFlip:int):Boolean 
		{
			var success:Boolean = super.collectRenderElements(collector, forceCalcMatrix, forceCalcColor, worldFlip);
			if (!success || !_geometry.isUploaded)
			{
				return false;
			}
			
			var n:int = surfaces.length;
			for (var i:int = 0; i < n; i++) 
			{
				var surface:Surface = surfaces[i];
				var material:Material = surface.material;
				if (material == null) continue;
				
				var shaderList:ShaderList = material.getSpriteShaderList(collector, this);
				
				var element:RenderElement = (renderElements.length > i)? renderElements[i] : null;
				if (element == null)
				{
					element = renderElements[i] = new RenderElement();
				}
				element.firstIndex = surface.firstIndex;
				element.numTriangles = surface.numTriangles;
				element.matrix = _worldMatrix;
				element.vertexBufferFormatList = _geometry.vertexBufferFormatList;
				element.vertexBufferList = _geometry.vertexBufferList;
				element.indexBuffer = _geometry.indexBuffer;
				element.sourceFactor = surface.material.sourceFactor;
				element.destinationFactor = surface.material.destinationFactor;
				//マイナススケールでフリップしていた場合は表示を反転する
				element.culling = (worldFlip * flip == -1)? TriangleFace.BACK : TriangleFace.FRONT;//material.culling;
				element.shaderList = shaderList;
				element.layer = RenderLayer.OVERLAY;
				element.sortPriority = 0;
				
				collector.addRenderElement(element);
			}
			
			return true;
		}
		
	}

}