package net.morocoshi.moja3d.primitives 
{
	import net.morocoshi.moja3d.materials.Material;
	import net.morocoshi.moja3d.objects.Mesh;
	import net.morocoshi.moja3d.objects.Surface;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class Plane extends Mesh 
	{
		public function Plane(width:Number, height:Number, segmentsW:int, segmentsH:int, originX:Number, originY:Number, twoSides:Boolean, topMaterial:Material, bottomMaterial:Material) 
		{
			super();
			
			var vertices:Vector.<Number> = new Vector.<Number>;
			var colors:Vector.<Number> = new Vector.<Number>;
			var uvs:Vector.<Number> = new Vector.<Number>;
			var normals:Vector.<Number> = new Vector.<Number>;
			var tangent4:Vector.<Number> = new Vector.<Number>;
			var indices:Vector.<uint> = new Vector.<uint>;
			var count:int = -1;
			
			for (var g:int = 0; g < int(twoSides) + 1; g++)
			for (var iy:int = 0; iy <= segmentsH; iy++)
			for (var ix:int = 0; ix <= segmentsW; ix++)
			{
				count++;
				var px:Number = ix / segmentsW * width - width * originX;
				var py:Number = iy / segmentsH * height - height * originY;
				vertices.push(px, py, 0);
				colors.push(0.8, 1, 0.8, 1);
				uvs.push(1 - ix / segmentsW, iy / segmentsH);
				normals.push(0, 0, g == 0? 1 : -1);
				tangent4.push(1, 0, 0, 1);
				if (ix < segmentsW && iy < segmentsH)
				{
					var wnum:int = segmentsW + 1;
					if (g == 0)
					{
						indices.push(count, count + 1, count + wnum);
						indices.push(count + wnum, count + 1, count + wnum + 1);
					}
					else
					{
						indices.push(count, count + wnum, count + 1);
						indices.push(count + wnum, count + wnum + 1, count + 1);
					}
				}
			}
			
			geometry.addVertices(VertexAttribute.POSITION, 3, vertices);
			geometry.addVertices(VertexAttribute.UV, 2, uvs);
			geometry.addVertices(VertexAttribute.NORMAL, 3, normals);
			geometry.addVertices(VertexAttribute.VERTEX_COLOR, 4, colors);
			geometry.addVertices(VertexAttribute.TANGENT4, 4, tangent4);
			geometry.vertexIndices = indices;
			
			var tri:int = segmentsH * segmentsW * 2;
			surfaces.push(new Surface(topMaterial, 0, tri));
			if (twoSides)
			{
				surfaces.push(new Surface(bottomMaterial, tri * 3, tri));
			}
			
			calculateBounds();
		}
		
	}

}