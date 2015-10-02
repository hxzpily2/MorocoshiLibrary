package net.morocoshi.moja3d.primitives 
{
	import net.morocoshi.moja3d.materials.Material;
	import net.morocoshi.moja3d.objects.Mesh;
	import net.morocoshi.moja3d.objects.Surface;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class Sphere extends Mesh 
	{
		
		public function Sphere(radius:Number, segmentsW:int, segmentsH:int, material:Material) 
		{
			super();
			
			var vertices:Vector.<Number> = new Vector.<Number>;
			var colors:Vector.<Number> = new Vector.<Number>;
			var uvs:Vector.<Number> = new Vector.<Number>;
			var normals:Vector.<Number> = new Vector.<Number>;
			var tangent4:Vector.<Number> = new Vector.<Number>;
			var indices:Vector.<uint> = new Vector.<uint>;
			var count:int = -1;
			
			for (var iy:int = 0; iy <= segmentsH; iy++) 
			for (var ix:int = 0; ix <= segmentsW; ix++) 
			{
				count++;
				var rotateW:Number = ix / segmentsW * Math.PI * 2;
				var rotateH:Number = (iy / segmentsH - 0.5) * Math.PI;
				var cosH:Number = Math.cos(rotateH);
				var px:Number = Math.cos(rotateW) * cosH;
				var py:Number = Math.sin(rotateW) * cosH;
				var pz:Number = Math.sin(rotateH);
				vertices.push(px * radius, py * radius, pz * radius);
				colors.push(1, 1, 1, 1);
				uvs.push(ix / segmentsW, iy / segmentsH);
				normals.push(px, py, pz);
				tangent4.push(1, 0, 0, 1);
				
				if (ix < segmentsW && iy < segmentsH)
				{
					var wnum:int = segmentsW + 1;
					indices.push(count, count + 1, count + wnum);
					indices.push(count + wnum, count + 1, count + wnum + 1);
				}
			}
			geometry.addVertices(VertexAttribute.POSITION, 3, vertices);
			geometry.addVertices(VertexAttribute.VERTEX_COLOR, 4, colors);
			geometry.addVertices(VertexAttribute.UV, 2, uvs);
			geometry.addVertices(VertexAttribute.NORMAL, 3, normals);
			geometry.addVertices(VertexAttribute.TANGENT4, 4, tangent4);
			geometry.vertexIndices = indices;
			surfaces.push(new Surface(material, 0, indices.length / 3)); //segmentsH * segmentsW * 2
			calculateBounds();
		}
		
	}

}