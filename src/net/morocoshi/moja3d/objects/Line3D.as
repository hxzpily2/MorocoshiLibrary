package net.morocoshi.moja3d.objects 
{
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.materials.Material;
	import net.morocoshi.moja3d.renderer.RenderCollector;
	import net.morocoshi.moja3d.resources.Geometry;
	import net.morocoshi.moja3d.resources.LineGeometry;
	import net.morocoshi.moja3d.shaders.ShaderList;
	import net.morocoshi.moja3d.shaders.line.LineEndShader;
	import net.morocoshi.moja3d.shaders.line.LineShader;
	import net.morocoshi.moja3d.view.ContextProxy;
	
	use namespace moja3d;
	
	/**
	 * ラインオブジェクト
	 * 
	 * @author tencho
	 */
	public class Line3D extends Mesh 
	{
		private var context3D:ContextProxy;
		private var surface:Surface;
		private var lineShader:LineShader;
		
		public function Line3D() 
		{
			super();
			_geometry = new LineGeometry();
			surface = new Surface(new Material(), 0, 0);
			surfaces.push(surface);
			mouseEnabled = false;
			
			lineShader = new LineShader(_geometry);
			startShaderList = new ShaderList();
			startShaderList.addShader(lineShader);
			lastShader = new LineEndShader(_geometry);
			//afterViewShaderList = new ShaderList();
			//afterViewShaderList.addShader(new LineEndShader(_geometry));
		}
		
		override moja3d function collectRenderElements(collector:RenderCollector, forceCalcMatrix:Boolean, forceCalcColor:Boolean, forceCalcBounds:Boolean, worldFlip:int, mask:int):Boolean 
		{
			lineShader.setAlphaTransform(lineGeometry.alphaTransform);
			surface.numTriangles = lineGeometry.numTriangles;
			return super.collectRenderElements(collector, forceCalcMatrix, forceCalcColor, forceCalcBounds, worldFlip, mask);
		}
		
		override public function get geometry():Geometry 
		{
			return super.geometry;
		}
		
		override public function set geometry(value:Geometry):void 
		{
			lineShader.geometry = value;
			super.geometry = value;
		}
		
		public function get lineGeometry():LineGeometry
		{
			return _geometry as LineGeometry;
		}
		
		override public function clone():Object3D 
		{
			var mesh:Line3D = new Line3D();
			cloneProperties(mesh);
			//子を再帰的にコピーする
			var current:Object3D;
			for (current = _children; current; current = current._next)
			{
				mesh.addChild(current.clone());
			}
			return mesh;
		}
		
		override public function reference():Object3D 
		{
			var mesh:Line3D = new Line3D();
			referenceProperties(mesh);
			//子を再帰的にコピーする
			var current:Object3D;
			for (current = _children; current; current = current._next)
			{
				mesh.addChild(current.reference());
			}
			return mesh;
		}
		
	}

}