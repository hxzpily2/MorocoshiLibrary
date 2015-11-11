package net.morocoshi.moja3d.primitives 
{
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import net.morocoshi.moja3d.materials.Material;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.objects.Mesh;
	import net.morocoshi.moja3d.objects.Surface;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.scale9.Scale9Shader;
	import net.morocoshi.moja3d.shaders.ShaderList;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class Scale9Plane extends Mesh 
	{
		private var _scale9Grid:Rectangle;
		private var scale9Shader:Scale9Shader;
		private var min:Point;
		private var max:Point;
		private var baseWidth:Number;
		private var baseHeight:Number;
		
		/**
		 * 
		 * @param	width	幅
		 * @param	height	高さ
		 * @param	scale9Grid	9分割した中央のセルの矩形
		 * @param	originX	基点の位置。0.5で中央
		 * @param	originY	基点の位置。0.5で中央
		 * @param	twoSides	両面にポリゴンを貼るか
		 * @param	topMaterial	前面マテリアル
		 * @param	bottomMaterial	背面マテリアル
		 */
		public function Scale9Plane(width:Number, height:Number, scale9Grid:Rectangle, originX:Number, originY:Number, twoSides:Boolean, topMaterial:Material, bottomMaterial:Material) 
		{
			super();
			
			_scale9Grid = scale9Grid;
			baseWidth = width;
			baseHeight = height;
			
			var segmentsW:int = 3;
			var segmentsH:int = 3;
			var vertices:Vector.<Number> = new Vector.<Number>;
			var colors:Vector.<Number> = new Vector.<Number>;
			var uvs:Vector.<Number> = new Vector.<Number>;
			var normals:Vector.<Number> = new Vector.<Number>;
			var tangent4:Vector.<Number> = new Vector.<Number>;
			var scale9s:Vector.<Number> = new Vector.<Number>;
			var indices:Vector.<uint> = new Vector.<uint>;
			var count:int = -1;
			
			min = new Point( -width * (1 - originX), -height * (1 - originY));
			max = new Point(min.x + width, min.y + height);
			var lineX:Array = [min.x, min.x + scale9Grid.left, min.x + scale9Grid.right, min.x + width];
			var lineY:Array = [min.y, min.y + scale9Grid.top, min.y + scale9Grid.bottom, min.y + height];
			for (var g:int = 0; g < int(twoSides) + 1; g++)
			for (var iy:int = 0; iy <= segmentsH; iy++)
			for (var ix:int = 0; ix <= segmentsW; ix++)
			{
				count++;
				vertices.push(lineX[ix], lineY[iy], 0);
				colors.push(1, 1, 1, 1);
				uvs.push(1 - (lineX[ix] - min.x) / width, (lineY[iy] - min.y) / height);
				normals.push(0, 0, g == 0? 1 : -1);
				tangent4.push(1, 0, 0, 1);
				scale9s.push(int(ix == 1), int(ix == 2), int(iy == 1), int(iy == 2));
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
			geometry.addVertices(VertexAttribute.VERTEXCOLOR, 4, colors);
			geometry.addVertices(VertexAttribute.UV, 2, uvs);
			geometry.addVertices(VertexAttribute.NORMAL, 3, normals);
			geometry.addVertices(VertexAttribute.TANGENT4, 4, tangent4);
			geometry.addVertices(VertexAttribute.SCALE9, 4, scale9s);
			geometry.vertexIndices = indices;
			
			var tri:int = segmentsH * segmentsW * 2;
			surfaces.push(new Surface(topMaterial, 0, tri));
			if (twoSides)
			{
				surfaces.push(new Surface(bottomMaterial, tri * 3, tri));
			}
			
			scale9Shader = new Scale9Shader(geometry);
			beforeMatrixShaderList = new ShaderList();
			beforeMatrixShaderList.addShader(scale9Shader);
			updateScale9();
			calculateBounds();
		}
		
		override public function set scaleX(value:Number):void 
		{
			super.scaleX = value;
			updateScale9();
		}
		
		override public function set scaleY(value:Number):void 
		{
			super.scaleY = value;
			updateScale9();
		}
		
		override public function set matrix(value:Matrix3D):void 
		{
			super.matrix = value;
			updateScale9();
		}
		
		public function get scale9Grid():Rectangle 
		{
			return _scale9Grid;
		}
		
		/**
		 * scaleXを調整してこの幅になるようにします
		 */
		public function get width():Number 
		{
			return baseWidth * scaleX;
		}
		
		public function set width(value:Number):void 
		{
			scaleX = value / baseWidth;
		}
		
		/**
		 * scaleYを調整してこの高さになるようにします
		 */
		public function get height():Number 
		{
			return baseHeight * scaleY;
		}
		
		public function set height(value:Number):void 
		{
			scaleY = value / baseHeight;
		}
		
		private function updateScale9():void 
		{
			var x1:Number = _scale9Grid.left / scaleX;
			var x2:Number = (baseWidth - _scale9Grid.right) / scaleX;
			if (x1 + x2 > baseWidth)
			{
				var tx1:Number = baseWidth * x1 / (x1 + x2);
				var tx2:Number = baseWidth * x2 / (x1 + x2);
				x1 = tx1;
				x2 = tx2;
			}
			var y1:Number = _scale9Grid.top / scaleY;
			var y2:Number = (baseHeight - _scale9Grid.bottom) / scaleY;
			if (y1 + y2 > baseHeight)
			{
				var ty1:Number = baseHeight * y1 / (y1 + y2);
				var ty2:Number = baseHeight * y2 / (y1 + y2);
				y1 = ty1;
				y2 = ty2;
			}
			
			scale9Shader.x1 = min.x + x1;
			scale9Shader.x2 = max.x - x2;
			scale9Shader.y1 = min.y + y1;
			scale9Shader.y2 = max.y - y2;
		}
		
	}

}