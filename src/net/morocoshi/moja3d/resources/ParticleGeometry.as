package net.morocoshi.moja3d.resources 
{
	import net.morocoshi.common.math.transform.AngleUtil;
	import net.morocoshi.moja3d.particle.cells.ParticleData;
	import net.morocoshi.moja3d.particle.cells.ParticleList;
	import net.morocoshi.moja3d.view.ContextProxy;
	
	/**
	 * パーティクル用ジオメトリ
	 * 
	 * @author tencho
	 */
	public class ParticleGeometry extends Geometry 
	{
		private var vertices:Vector.<Number>;
		private var sizes:Vector.<Number>;
		private var uvs:Vector.<Number>;
		private var colors:Vector.<Number>;
		
		public function ParticleGeometry() 
		{
			super();
			
			vertices = new Vector.<Number>;
			sizes = new Vector.<Number>;
			uvs = new Vector.<Number>;
			colors = new Vector.<Number>;
			addVertices(VertexAttribute.POSITION, 3, vertices);
			addVertices(VertexAttribute.UV, 2, uvs);
			addVertices(VertexAttribute.VERTEXCOLOR, 4, colors);
			addVertices(VertexAttribute.SIZE, 3, sizes);
			vertexIndices = new Vector.<uint>;
		}
		
		override public function upload(context3D:ContextProxy, async:Boolean = false, complete:Function = null):void 
		{
			if (vertexIndices.length == 0)
			{
				dispose();
				return;
			}
			super.upload(context3D, async, complete);
		}
		
		public function update(particleList:ParticleList, context3D:ContextProxy):void
		{
			vertices.length = 0;
			sizes.length = 0;
			uvs.length = 0;
			colors.length = 0;
			vertexIndices.length = 0;
			
			var offset:int = 0;
			//var n:int = particles.length;
			//var i:int = 0;
			for (var p:ParticleData = particleList.root; p; p = p.next) 
			{
				var pr:Number = p.rotation;
				var px:Number = p.x;
				var py:Number = p.y;
				var pz:Number = p.z;
				var w0:Number = -p.width;
				var w1:Number = p.width;
				var h0:Number = -p.height;
				var h1:Number = p.height;
				var u0:Number = p.u0;
				var u1:Number = p.u1;
				var v0:Number = p.v0;
				var v1:Number = p.v1;
				var alpha:Number = p.alpha;
				vertices.push(px, py, pz, px, py, pz, px, py, pz, px, py, pz);
				uvs.push(u0, v0, u1, v0, u0, v1, u1, v1);
				sizes.push(w0, h0, pr, w1, h0, pr, w0, h1, pr, w1, h1, pr);
				colors.push(1, 1, 1, alpha, 1, 1, 1, alpha, 1, 1, 1, alpha, 1, 1, 1, alpha);
				vertexIndices.push(offset, offset + 2, offset + 1, offset + 1, offset + 2, offset + 3);
				offset += 4;
			}
			
			dispose();
			upload(context3D, false);
		}
		
	}

}