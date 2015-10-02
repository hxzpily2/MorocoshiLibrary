package net.morocoshi.moja3d.resources 
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Vector3D;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class Geometry extends Resource
	{
		public var verticesList:Vector.<Vector.<Number>>;
		public var numAttributeList:Vector.<int>;
		public var vertexIndices:Vector.<uint>;
		
		public var vertexBufferFormatList:Vector.<String>;
		public var vertexBufferList:Vector.<VertexBuffer3D>;
		public var indexBuffer:IndexBuffer3D;
		private var attributeIndex:Object;
		
		public function Geometry() 
		{
			super();
			
			name = String(Math.random() * 10000 | 0);
			attributeIndex = { };
			verticesList = new Vector.<Vector.<Number>>;
			numAttributeList = new Vector.<int>;
			vertexIndices = new Vector.<uint>;
			
			vertexBufferFormatList = new Vector.<String>;
			vertexBufferList = new Vector.<VertexBuffer3D>;
		}
		
		public function hasAttribute(kind:int):Boolean
		{
			return attributeIndex.hasOwnProperty(String(kind));
		}
		
		public function get numTriangles():int
		{
			return vertexIndices.length / 3;
		}
		
		/**
		 * 頂点情報の登録
		 * @param	index	context3D.setVertexBufferAtで登録する時のインデックス？
		 * @param	numAttribute	1頂点にいくつの要素があるか。XYZなら3、UVなら2
		 * @param	vertices	全頂点の全要素を並べた配列
		 */
		public function addVertices(kind:int, numAttribute:int, vertices:Vector.<Number>):void
		{
			if (vertices == null)
			{
				throw new Error("頂点配列情報にnullを登録しようとしています！");
			}
			if (hasAttribute(kind))
			{
				var index:int = getAttributeIndex(kind);
				verticesList[index] = vertices;
				numAttributeList[index] = numAttribute;
				return;
			}
			
			verticesList.push(vertices);
			numAttributeList.push(numAttribute);
			attributeIndex[String(kind)] = verticesList.length - 1;
		}
		
		public function removeVertices(kind:int):void 
		{
			if (hasAttribute(kind) == false) return;
			
			var index:int = getAttributeIndex(kind);
			verticesList.splice(index, 1);
			numAttributeList.splice(index, 1);
			
			delete attributeIndex[String(kind)];
		}
		
		/**
		 * 
		 * @param	kind
		 * @return
		 */
		public function getAttributeIndex(kind:int):int 
		{
			return hasAttribute(kind)? attributeIndex[String(kind)] : -1;
		}
		
		/**
		 * 
		 * @param	index
		 * @return
		 */
		public function getVertices(kind:int):Vector.<Number>
		{
			return verticesList[attributeIndex[kind]];
		}
		
		/**
		 * Context3Dに頂点バッファなどを転送
		 * @param	context3D
		 * @param	async
		 * @param	complete
		 */
		override public function upload(context3D:Context3D, async:Boolean, complete:Function = null):void
		{
			dispose();
			
			if (vertexIndices.length > 524287)
			{
				return;
			}
			
			super.upload(context3D, async, complete);
			
			var i:int;
			var n:int;
			n = numAttributeList.length;
			for (i = 0; i < n; i++) 
			{
				var numAttribute:int = numAttributeList[i];
				vertexBufferFormatList[i] = getVertexFormat(numAttribute);
				if (verticesList[i] == null)
				{
					dispose();
					return;
				}
				var numVertices:int = verticesList[i].length / numAttribute;
				if (numVertices > 65535)
				{
					dispose();
					return;
				}
				var vertexBuffer:VertexBuffer3D = context3D.createVertexBuffer(numVertices, numAttribute);
				vertexBufferList[i] = vertexBuffer;
				vertexBuffer.uploadFromVector(verticesList[i], 0, numVertices);
			}
			
			try
			{
				indexBuffer = context3D.createIndexBuffer(vertexIndices.length);
				indexBuffer.uploadFromVector(vertexIndices, 0, vertexIndices.length);
			}
			catch (e:Error)
			{
				dispose();
				return;
			}
			
			if (complete != null)
			{
				complete(this);
			}
		}
		
		override public function dispose():void 
		{
			super.dispose();
			var i:int;
			var n:int;
			
			n = vertexBufferList.length;
			for (i = 0; i < n; i++) 
			{
				if (vertexBufferList[i])
				{
					vertexBufferList[i].dispose();
				}
			}
			if (indexBuffer)
			{
				indexBuffer.dispose();
			}
			indexBuffer = null;
			vertexBufferList.length = 0;
			vertexBufferFormatList.length = 0;
		}
		
		override public function clone():Resource 
		{
			var geometry:Geometry = new Geometry();
			geometry.vertexIndices = vertexIndices.concat();
			geometry.numAttributeList = numAttributeList.concat();
			geometry.vertexBufferFormatList = vertexBufferFormatList.concat();
			geometry.verticesList = new Vector.<Vector.<Number>>;
			var n:int = verticesList.length;
			for (var i:int = 0; i < n; i++) 
			{
				geometry.verticesList.push(verticesList[i].concat());
			}
			return geometry;
		}
		
		/**
		 * 全頂点座標リストをVector3Dで取得（重複座標も含まれる可能性あり）
		 * @return
		 */
		public function getVertexList():Vector.<Vector3D> 
		{
			var result:Vector.<Vector3D> = new Vector.<Vector3D>;
			var points:Vector.<Number> = getVertices(VertexAttribute.POSITION);
			var n:int = points.length;
			for (var i:int = 0; i < n; i += 3)
			{
				result.push(new Vector3D(points[i], points[i + 1], points[i + 2]));
			}
			return result;
		}
		
		private function getVertexFormat(num:int):String 
		{
			switch(num)
			{
				case 4: return Context3DVertexBufferFormat.FLOAT_4;
				case 3: return Context3DVertexBufferFormat.FLOAT_3;
				case 2: return Context3DVertexBufferFormat.FLOAT_2;
				case 1: return Context3DVertexBufferFormat.FLOAT_1;
			}
			return "";
		}
		
	}

}