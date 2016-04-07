package net.morocoshi.moja3d.resources 
{
	import flash.geom.Vector3D;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.bounds.BoundingBox;
	import net.morocoshi.moja3d.shaders.AlphaState;
	import net.morocoshi.moja3d.shaders.AlphaTransform;
	import net.morocoshi.moja3d.view.ContextProxy;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class LineGeometry extends Geometry 
	{
		public var segmentList:Vector.<LineSegment>;
		public var alphaTransform:uint;
		private var vertices:Vector.<Number>;
		private var vectors:Vector.<Number>;
		private var uvs:Vector.<Number>;
		private var colors:Vector.<Number>;
		private var thicknesses:Vector.<Number>;
		
		public function LineGeometry() 
		{
			super();
			alphaTransform = AlphaTransform.UNCHANGE;
			segmentList = new Vector.<LineSegment>;
			
			vertices = new Vector.<Number>;
			vectors = new Vector.<Number>;
			uvs = new Vector.<Number>;
			colors = new Vector.<Number>;
			thicknesses = new Vector.<Number>;
			addVertices(VertexAttribute.POSITION, 3, vertices);
			addVertices(VertexAttribute.UV, 2, uvs);
			addVertices(VertexAttribute.VERTEXCOLOR, 4, colors);
			addVertices(VertexAttribute.LINE_VECTOR, 4, vectors);
			vertexIndices = new Vector.<uint>;
		}
		
		override public function calculateBounds(boundingBox:BoundingBox):void 
		{
			var minX:Number = Number.MAX_VALUE;
			var minY:Number = Number.MAX_VALUE;
			var minZ:Number = Number.MAX_VALUE;
			var maxX:Number = -Number.MAX_VALUE;
			var maxY:Number = -Number.MAX_VALUE;
			var maxZ:Number = -Number.MAX_VALUE;
			
			var n:int = segmentList.length;
			for (var i:int = 0; i < n; i++)
			{
				var segment:LineSegment = segmentList[i];
				var m:int = segment.pointList.length;
				for (var j:int = 0; j < m; j++)
				{
					var p:LinePoint = segment.pointList[j];
					if (minX > p.x) minX = p.x;
					if (minY > p.y) minY = p.y;
					if (minZ > p.z) minZ = p.z;
					if (maxX < p.x) maxX = p.x;
					if (maxY < p.y) maxY = p.y;
					if (maxZ < p.z) maxZ = p.z;
				}
			}
			
			boundingBox.minX = minX;
			boundingBox.minY = minY;
			boundingBox.minZ = minZ;
			boundingBox.maxX = maxX;
			boundingBox.maxY = maxY;
			boundingBox.maxZ = maxZ;
		}
		
		override public function upload(context3D:ContextProxy, async:Boolean = false, complete:Function = null):Boolean 
		{
			if (vertexIndices.length == 0)
			{
				dispose();
				return false;
			}
			return super.upload(context3D, async, complete);
		}
		
		public function update(context3D:ContextProxy):void 
		{
			vertices.length = 0;
			vectors.length = 0;
			uvs.length = 0;
			colors.length = 0;
			thicknesses.length = 0;
			vertexIndices.length = 0;
			
			var alphaElement:uint = 0;
			var offset:int = 0;
			var n:int = segmentList.length;
			for (var i:int = 0; i < n; i++)
			{
				var segment:LineSegment = segmentList[i];
				var thick:Number = segment.thickness * 0.5;
				var j:int;
				var m:int = segment.pointList.length;
				for (j = 0; j < m; j++)
				{
					var a:Number = segment.pointList[j].alpha;
					if (a < 1) alphaElement |= 0xf00;
					if (a == 1) alphaElement |= 0x0f0;
					if (a > 1) alphaElement |= 0x00f;
				}
				for (j = 0; j < m - 1; j++)
				{
					var p1:LinePoint = segment.pointList[j];
					var p2:LinePoint = segment.pointList[j + 1];
					vertices.push(p1.x, p1.y, p1.z);
					vertices.push(p1.x, p1.y, p1.z);
					vertices.push(p2.x, p2.y, p2.z);
					vertices.push(p2.x, p2.y, p2.z);
					var vx:Number = p2.x - p1.x;
					var vy:Number = p2.y - p1.y;
					var vz:Number = p2.z - p1.z;
					vectors.push(vx, vy, vz, thick, -vx, -vy, -vz, thick, vx, vy, vz, thick, -vx, -vy, -vz, thick);
					colors.push(p1.r, p1.g, p1.b, p1.alpha);
					colors.push(p1.r, p1.g, p1.b, p1.alpha);
					colors.push(p2.r, p2.g, p2.b, p2.alpha);
					colors.push(p2.r, p2.g, p2.b, p2.alpha);
					uvs.push(0, 0);
					uvs.push(1, 0);
					uvs.push(0, 1);
					uvs.push(1, 1);
					vertexIndices.push(offset + 0, offset + 1, offset + 2);
					vertexIndices.push(offset + 2, offset + 1, offset + 3);
					offset += 4;
				}
			}
			
			if (alphaElement & 0x00f) alphaTransform = AlphaTransform.SET_UNKNOWN;
			else if ((alphaElement & 0xff0) == 0xff0) alphaTransform = AlphaTransform.SET_MIXTURE;
			else if (alphaElement & 0x0f0) alphaTransform = AlphaTransform.SET_OPAQUE;
			else if (alphaElement & 0xf00) alphaTransform = AlphaTransform.SET_TRANSPARENT;
			else alphaTransform = AlphaTransform.UNCHANGE;
			
			dispose();
			upload(context3D, false);
		}
		
	}

}