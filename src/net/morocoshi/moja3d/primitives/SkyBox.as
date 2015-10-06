package net.morocoshi.moja3d.primitives 
{
	import net.morocoshi.moja3d.materials.Material;
	import net.morocoshi.moja3d.materials.TriangleFace;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.objects.Mesh;
	import net.morocoshi.moja3d.objects.Surface;
	import net.morocoshi.moja3d.renderer.RenderCollector;
	import net.morocoshi.moja3d.resources.CubeTextureResource;
	import net.morocoshi.moja3d.resources.ImageTextureResource;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.render.FillShader;
	import net.morocoshi.moja3d.shaders.render.SkyBoxShader;
	import net.morocoshi.moja3d.shaders.render.TextureShader;
	
	use namespace moja3d;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class SkyBox extends Mesh 
	{
		
		public function SkyBox(size:Number, texture:ImageTextureResource) 
		{
			super();
			
			castShadow = false;
			
			var vertices:Vector.<Number> = new Vector.<Number>;
			var uvs:Vector.<Number> = new Vector.<Number>;
			var normals:Vector.<Number> = new Vector.<Number>;
			var indices:Vector.<uint> = new Vector.<uint>;
			var count:int = -1;
			
			var num:int;
			var i:int;
			var ix:int;
			var iy:int;
			var iz:int;
			var half:Number = size * 0.5;
			var ratioX:Number;
			var ratioY:Number;
			var ratioZ:Number;
			
			num = 1 + 1;
			for (iz = 0; iz <= 1; iz++)
			for (iy = 0; iy <= 1; iy++)
			for (ix = 0; ix <= 1; ix++)
			{
				count++;
				ratioX = ix;
				ratioY = iy;
				ratioZ = iz;
				vertices.push(ratioX * size - half, ratioY * size - half, ratioZ * size - half);
				uvs.push(ratioX, iz? 1 - ratioY : ratioY);
				normals.push(0, 0, ratioZ * 2 - 1);
				if (ix < 1 && iy < 1)
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
			
			num = 1 + 1;
			for (ix = 0; ix <= 1; ix++)
			for (iz = 0; iz <= 1; iz++)
			for (iy = 0; iy <= 1; iy++)
			{
				count++;
				ratioX = ix;
				ratioY = iy;
				ratioZ = iz;
				vertices.push(ratioX * size - half, ratioY * size - half, ratioZ * size - half);
				uvs.push(ix? ratioY : 1 - ratioY, 1 - ratioZ);
				normals.push(ratioX * 2 - 1, 0, 0);
				if (iy < 1 && iz < 1)
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
			
			num = 1 + 1;
			for (iy = 0; iy <= 1; iy++)
			for (iz = 0; iz <= 1; iz++)
			for (ix = 0; ix <= 1; ix++)
			{
				count++;
				ratioX = ix;
				ratioY = iy;
				ratioZ = iz;
				vertices.push(ratioX * size - half, ratioY * size - half, ratioZ * size - half);
				uvs.push(iy? 1 - ratioX : ratioX, 1 - ratioZ);
				normals.push(0, ratioY * 2 - 1, 0);
				if (ix < 1 && iz < 1)
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
			geometry.addVertices(VertexAttribute.UV, 2, uvs);
			geometry.addVertices(VertexAttribute.NORMAL, 3, normals);
			geometry.vertexIndices = indices;
			
			var material:Material = new Material();
			material.culling = TriangleFace.BACK;
			material.shaderList.addShader(new SkyBoxShader(texture));
			setMaterialToAllSurfaces(material);
			
			//calculateBounds();
		}
		
		override protected function collecting(collector:RenderCollector):void 
		{
			_worldMatrix.copyFrom(collector.camera.worldMatrix);
		}
		
	}

}