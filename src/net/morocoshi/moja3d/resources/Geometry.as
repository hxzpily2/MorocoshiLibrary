package net.morocoshi.moja3d.resources 
{
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Vector3D;
	import flash.utils.getQualifiedClassName;
	import net.morocoshi.common.data.DataUtil;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.agal.AGALInfo;
	import net.morocoshi.moja3d.bounds.BoundingBox;
	import net.morocoshi.moja3d.collision.CollisionMesh;
	import net.morocoshi.moja3d.view.ContextProxy;
	
	use namespace moja3d;
	
	/**
	 * メッシュジオメトリ
	 * 
	 * @author tencho
	 */
	public class Geometry extends Resource
	{
		public var verticesList:Vector.<Vector.<Number>>;
		public var numAttributeList:Vector.<int>;
		public var vertexIndices:Vector.<uint>;
		
		moja3d var attributesKey:String;
		public var vertexBufferFormatList:Vector.<String>;
		public var vertexBufferList:Vector.<VertexBuffer3D>;
		public var indexBuffer:IndexBuffer3D;
		public var seed:int;
		private var attributeIndex:Object;
		moja3d var collision:CollisionMesh;
		static private var seedCount:int = 0;
		
		public function Geometry() 
		{
			super();
			
			seed = ++seedCount;
			name = "";
			attributeIndex = { };
			verticesList = new Vector.<Vector.<Number>>;
			numAttributeList = new Vector.<int>;
			vertexIndices = new Vector.<uint>;
			
			vertexBufferFormatList = new Vector.<String>;
			vertexBufferList = new Vector.<VertexBuffer3D>;
			
			updateAttributeKey();
		}
		
		override public function toString():String 
		{
			return "[" + getQualifiedClassName(this).split("::")[1] + " tri=" + numTriangles + "," + isUploaded + "]";
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
			
			updateAttributeKey();
		}
		
		private function updateAttributeKey():void 
		{
			var list:Array = [];
			for (var key:String in attributeIndex)
			{
				list.push( { index:attributeIndex[key], kind:key } );
			}
			list.sortOn("index", Array.NUMERIC);
			
			attributesKey = "";
			var n:int = list.length;
			for (var i:int = 0; i < n; i++) 
			{
				attributesKey += list[i].index + ":" + list[i].kind + "_";
			}
		}
		
		public function removeVertices(kind:int):void 
		{
			if (hasAttribute(kind) == false) return;
			
			var index:int = getAttributeIndex(kind);
			verticesList.splice(index, 1);
			numAttributeList.splice(index, 1);
			
			delete attributeIndex[String(kind)];
			
			updateAttributeKey();
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
		 * @param	kind
		 * @return
		 */
		public function getVertices(kind:int):Vector.<Number>
		{
			return verticesList[attributeIndex[kind]];
		}
		
		/**
		 * Context3Dに頂点バッファなどを転送
		 * @param	context3D
		 */
		override public function upload(context3D:ContextProxy):Boolean
		{
			if (super.upload(context3D) == false) return false;
			
			if (vertexIndices.length > AGALInfo.VERTEXINDEX_LIMIT)
			{
				trace("頂点インデックス数の上限は" + AGALInfo.VERTEXINDEX_LIMIT + "です(" + vertexIndices.length + ")");
				dispose();
				return false;
			}
			
			var i:int;
			var n:int;
			
			var vertexBuffer:VertexBuffer3D;
			
			n = numAttributeList.length;
			for (i = 0; i < n; i++) 
			{
				var numAttribute:int = numAttributeList[i];
				vertexBufferFormatList[i] = getVertexFormat(numAttribute);
				if (verticesList[i] == null)
				{
					dispose();
					vertexBuffer = null;
					return false;
				}
				var numVertices:int = verticesList[i].length / numAttribute;
				if (numVertices > AGALInfo.VERTEXDATA_LIMIT)
				{
					trace("頂点数の上限は" + AGALInfo.VERTEXDATA_LIMIT + "です(" + numVertices + ")");
					dispose();
					vertexBuffer = null;
					return false;
				}
				vertexBuffer = context3D.context.createVertexBuffer(numVertices, numAttribute);
				vertexBufferList[i] = vertexBuffer;
				vertexBuffer.uploadFromVector(verticesList[i], 0, numVertices);
			}
			vertexBuffer = null;
			
			try
			{
				indexBuffer = context3D.context.createIndexBuffer(vertexIndices.length);
				indexBuffer.uploadFromVector(vertexIndices, 0, vertexIndices.length);
			}
			catch (e:Error)
			{
				dispose();
				return false;
			}
			
			return true;
		}
		
		override public function clear():void 
		{
			super.clear();
			
			DataUtil.deleteVector(vertexBufferList);
			DataUtil.deleteVector(vertexBufferFormatList);
			DataUtil.deleteVector(vertexIndices);
			DataUtil.deleteVector(numAttributeList);
			DataUtil.deleteVector(verticesList);
			DataUtil.deleteObject(attributeIndex);
			
			verticesList = null;
			numAttributeList = null;
			vertexIndices = null;
			vertexBufferFormatList = null;
			vertexBufferList = null;
			indexBuffer = null;
			attributeIndex = null;
		}
		
		override public function dispose():void 
		{
			super.dispose();
			
			var i:int;
			var n:int;
			
			if (vertexBufferList)
			{
				n = vertexBufferList.length;
				for (i = 0; i < n; i++) 
				{
					if (vertexBufferList[i])
					{
						vertexBufferList[i].dispose();
					}
				}
				vertexBufferList.length = 0;
			}
			
			if (indexBuffer)
			{
				indexBuffer.dispose();
				indexBuffer = null;
			}
			
			if (vertexBufferFormatList)
			{
				vertexBufferFormatList.length = 0;
			}
			
			if (collision)
			{
				collision.finaly();
				collision = null;
			}
		}
		
		override public function cloneProperties(target:Resource):void 
		{
			super.cloneProperties(target);
			
			var geometry:Geometry = target as Geometry;
			geometry.attributeIndex = { };
			
			for (var key:String in attributeIndex)
			{
				geometry.attributeIndex[key] = attributeIndex[key];
			}
			
			geometry.vertexIndices = vertexIndices.concat();
			geometry.numAttributeList = numAttributeList.concat();
			geometry.vertexBufferFormatList = vertexBufferFormatList.concat();
			geometry.verticesList = new Vector.<Vector.<Number>>;
			var n:int = verticesList.length;
			for (var i:int = 0; i < n; i++) 
			{
				geometry.verticesList.push(verticesList[i].concat());
			}
			geometry.collision = collision? collision.clone() : null;
			geometry = null;
		}
		
		override public function clone():Resource 
		{
			var geometry:Geometry = new Geometry();
			cloneProperties(geometry);
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
			points = null;
			return result;
		}
		
		public function calculateBounds(boundingBox:BoundingBox):void 
		{
			var items:Vector.<Number> = getVertices(VertexAttribute.POSITION);
			var i:int;
			var n:int = items.length;
			
			var minX:Number = Number.MAX_VALUE;
			var minY:Number = Number.MAX_VALUE;
			var minZ:Number = Number.MAX_VALUE;
			var maxX:Number = -Number.MAX_VALUE;
			var maxY:Number = -Number.MAX_VALUE;
			var maxZ:Number = -Number.MAX_VALUE;
			
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
			
			items = null;
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