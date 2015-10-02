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
	public class Cube extends Mesh 
	{
		
		public function Cube(sizeX:Number, sizeY:Number, sizeZ:Number, segmentsX:int, segmentsY:int, segmentsZ:int, material:Material) 
		{
			super();
			
			var vertices:Vector.<Number> = new Vector.<Number>;
			var colors:Vector.<Number> = new Vector.<Number>;
			var uvs:Vector.<Number> = new Vector.<Number>;
			var normals:Vector.<Number> = new Vector.<Number>;
			var tangent4:Vector.<Number> = new Vector.<Number>;
			var indices:Vector.<uint> = new Vector.<uint>;
			var count:int = -1;
			
			var num:int;
			var i:int;
			var ix:int;
			var iy:int;
			var iz:int;
			var halfX:Number = sizeX * 0.5;
			var halfY:Number = sizeY * 0.5;
			var halfZ:Number = sizeZ * 0.5;
			var ratioX:Number;
			var ratioY:Number;
			var ratioZ:Number;
			
			num = segmentsX + 1;
			for (iz = 0; iz <= 1; iz++)
			for (iy = 0; iy <= segmentsY; iy++)
			for (ix = 0; ix <= segmentsX; ix++)
			{
				count++;
				ratioX = ix / segmentsX;
				ratioY = iy / segmentsY;
				ratioZ = iz;
				vertices.push(ratioX * sizeX - halfX, ratioY * sizeY - halfY, ratioZ * sizeZ - halfZ);
				colors.push(1, 1, 1, 1);
				uvs.push(ratioX, iz? 1 - ratioY : ratioY);
				normals.push(0, 0, ratioZ * 2 - 1);
				tangent4.push(1, 1, 1, 1);
				if (ix < segmentsX && iy < segmentsY)
				{
					if (iz == 1)
					{
						indices.push(count, count + 1, count + num);
						indices.push(count + num, count + 1, count + num + 1);	
					}
					else
					{
						indices.push(count, count + num, count + 1);
						indices.push(count + num, count + num + 1, count + 1);	
					}
				}
			}
			
			num = segmentsY + 1;
			for (ix = 0; ix <= 1; ix++)
			for (iz = 0; iz <= segmentsZ; iz++)
			for (iy = 0; iy <= segmentsY; iy++)
			{
				count++;
				ratioX = ix;
				ratioY = iy / segmentsY;
				ratioZ = iz / segmentsZ;
				vertices.push(ratioX * sizeX - halfX, ratioY * sizeY - halfY, ratioZ * sizeZ - halfZ);
				colors.push(1, 1, 1, 1);
				uvs.push(ix? ratioY : 1 - ratioY, 1 - ratioZ);
				normals.push(ratioX * 2 - 1, 0, 0);
				tangent4.push(1, 1, 1, 1);
				if (iy < segmentsY && iz < segmentsZ)
				{
					if (ix == 1)
					{
						indices.push(count, count + 1, count + num);
						indices.push(count + num, count + 1, count + num + 1);	
					}
					else
					{
						indices.push(count, count + num, count + 1);
						indices.push(count + num, count + num + 1, count + 1);	
					}
				}
			}
			
			num = segmentsX + 1;
			for (iy = 0; iy <= 1; iy++)
			for (iz = 0; iz <= segmentsZ; iz++)
			for (ix = 0; ix <= segmentsX; ix++)
			{
				count++;
				ratioX = ix / segmentsX;
				ratioY = iy;
				ratioZ = iz / segmentsZ;
				vertices.push(ratioX * sizeX - halfX, ratioY * sizeY - halfY, ratioZ * sizeZ - halfZ);
				colors.push(1, 1, 1, 1);
				uvs.push(iy? 1 - ratioX : ratioX, 1 - ratioZ);
				normals.push(0, ratioY * 2 - 1, 0);
				tangent4.push(1, 1, 1, 1);
				if (ix < segmentsX && iz < segmentsZ)
				{
					if (iy == 0)
					{
						indices.push(count, count + 1, count + num);
						indices.push(count + num, count + 1, count + num + 1);	
					}
					else
					{
						indices.push(count, count + num, count + 1);
						indices.push(count + num, count + num + 1, count + 1);	
					}
				}
			}
			
			geometry.addVertices(VertexAttribute.POSITION, 3, vertices);
			geometry.addVertices(VertexAttribute.VERTEX_COLOR, 4, colors);
			geometry.addVertices(VertexAttribute.UV, 2, uvs);
			geometry.addVertices(VertexAttribute.NORMAL, 3, normals);
			geometry.addVertices(VertexAttribute.TANGENT4, 4, tangent4);
			geometry.vertexIndices = indices;
			
			setMaterialToAllSurfaces(material);
			calculateBounds();
		}
		
	}

}