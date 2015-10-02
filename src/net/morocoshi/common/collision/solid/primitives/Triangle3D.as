package net.morocoshi.common.collision.solid.primitives 
{
	import flash.geom.Vector3D;
	import net.morocoshi.common.collision.solid.bounds.AABB3D;
	import net.morocoshi.common.collision.solid.units.SphereUnit3D;
	import net.morocoshi.common.partitioning.cell2.Cell2DItem;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class Triangle3D 
	{
		public var instance:Collision3DMesh;
		public var aabb:AABB3D = new AABB3D();
		//a,b,cは三頂点
		public var a:Vector3D = new Vector3D();
		public var b:Vector3D = new Vector3D();
		public var c:Vector3D = new Vector3D();
		public var la:Vector3D = new Vector3D();
		public var lb:Vector3D = new Vector3D();
		public var lc:Vector3D = new Vector3D();
		//ab,bc,caは三辺のベクトル
		public var ab:Vector3D = new Vector3D();
		public var bc:Vector3D = new Vector3D();
		public var ca:Vector3D = new Vector3D();
		/**
		 * ポリゴン法線
		 */
		public var normal:Vector3D = new Vector3D();
		/**
		 * ポリゴンが正常かどうか。潰れてるとfalse
		 */
		public var valid:Boolean;
		/**
		 * デバッグ用
		 */
		public var index:int;
		
		public var cellItem:Cell2DItem;
		public var color:uint = Math.random() * 0xffffff;
		
		//このポリゴンが動いているかどうか。衝突判定時に更新される。
		//public var moved:Boolean;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 
		 */
		public function Triangle3D() 
		{
			cellItem = new Cell2DItem();
			cellItem.data = this;
		}
		
		//--------------------------------------------------------------------------
		//
		//  事前計算
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 
		 */
		public function calculate():void
		{
			aabb.xMin = min(a.x, b.x, c.x);
			aabb.yMin = min(a.y, b.y, c.y);
			aabb.zMin = min(a.z, b.z, c.z);
			aabb.xMax = max(a.x, b.x, c.x);
			aabb.yMax = max(a.y, b.y, c.y);
			aabb.zMax = max(a.z, b.z, c.z);
			
			//空間分割用アイテムサイズ
			cellItem.resize(aabb.xMin, aabb.yMin, aabb.xMax - aabb.xMin, aabb.yMax - aabb.yMin);
			
			ab.x = b.x - a.x;
			ab.y = b.y - a.y;
			ab.z = b.z - a.z;
			bc.x = c.x - b.x;
			bc.y = c.y - b.y;
			bc.z = c.z - b.z;
			ca.x = a.x - c.x;
			ca.y = a.y - c.y;
			ca.z = a.z - c.z;
			normal.x = (ab.y * -ca.z) - (ab.z * -ca.y);
			normal.y = (ab.z * -ca.x) - (ab.x * -ca.z);
			normal.z = (ab.x * -ca.y) - (ab.y * -ca.x);
			if (normal.x == 0 && normal.y == 0 && normal.z == 0)
			{
				valid = false;
				return;
			}
			valid = true;
			ab.normalize();
			bc.normalize();
			ca.normalize();
			normal.normalize();
		}
		
		private function max(a:Number, b:Number, c:Number):Number 
		{
			return (a >= b && a >= c)? a : (b > c)? b : c;
		}
		
		private function min(a:Number, b:Number, c:Number):Number 
		{
			return (a <= b && a <= c)? a : (b < c)? b : c;
		}
		
		//--------------------------------------------------------------------------
		//
		//  交差判定
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 点が三角形内にあるか
		 * @param	point
		 * @return
		 */
		public function contains(point:Vector3D):Boolean 
		{
			var n1:Vector3D = ab.crossProduct(point.subtract(a));
			var n2:Vector3D = bc.crossProduct(point.subtract(b));
			var n3:Vector3D = ca.crossProduct(point.subtract(c));
			if (n1.dotProduct(normal) < 0) return false;
			if (n2.dotProduct(normal) < 0) return false;
			if (n3.dotProduct(normal) < 0) return false;
			return true;
		}
		
		/**
		 * 指定座標に一番近い三角形の辺上の座標を返す
		 * @param	unit	半径とかチェックする用
		 * @param	point	この座標に近い点を調べる
		 * @return
		 */
		public function getNearPoint(unit:SphereUnit3D, point:Vector3D):Vector3D 
		{
			//var position:Vector3D = unit.position;
			var near1:Vector3D = getNearLinePoint(a, b, ab, point);
			var near2:Vector3D = getNearLinePoint(b, c, bc, point);
			var near3:Vector3D = getNearLinePoint(c, a, ca, point);
			
			var nx:Number;
			var ny:Number;
			var nz:Number;
			nx = near1.x - point.x;
			ny = near1.y - point.y;
			nz = near1.z - point.z;
			var n1:Number = nx * nx + ny * ny + nz * nz;
			nx = near2.x - point.x;
			ny = near2.y - point.y;
			nz = near2.z - point.z;
			var n2:Number = nx * nx + ny * ny + nz * nz;
			nx = near3.x - point.x;
			ny = near3.y - point.y;
			nz = near3.z - point.z;
			var n3:Number = nx * nx + ny * ny + nz * nz;
			
			//if (n1 <= n2 && n1 <= n3) return near1;
			//if (n2 <= n1 && n2 <= n3) return near2;
			//return near3;
			
			//%%%このやり方はまずいかも？そんな事はない？
			//移動量+半径が再接近点より遠ければ交差しない判定
			var r:Number = unit.radius + unit.displace.length;
			var rr:Number = r * r;
			if (n1 <= n2 && n1 <= n3) return (n1 > rr)? null : near1;
			if (n2 <= n1 && n2 <= n3) return (n2 > rr)? null : near2;
			return (n3 > rr)? null : near3;
		}
		
		/**
		 * 指定座標に一番近い辺上の点を求める
		 * @param	p0
		 * @param	p1
		 * @param	line
		 * @param	position
		 * @return
		 */
		private function getNearLinePoint(p0:Vector3D, p1:Vector3D, line:Vector3D, position:Vector3D):Vector3D 
		{
			var near:Vector3D = new Vector3D();
			
			var ap:Vector3D = position.subtract(p0);
			var bp:Vector3D = position.subtract(p1);
			if (line.dotProduct(ap) <= 0)
			{
				near.x = p0.x;
				near.y = p0.y;
				near.z = p0.z;
			}
			else if (line.dotProduct(bp) >= 0)
			{
				near.x = p1.x;
				near.y = p1.y;
				near.z = p1.z;
			}
			else
			{
				var d:Number = ap.dotProduct(line);
				near.x = line.x * d + p0.x;
				near.y = line.y * d + p0.y;
				near.z = line.z * d + p0.z;
			}
			
			return near;
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		/*
		%%%デバッグ用表示
		public function createWireList(rgb:uint, alpha:Number, thickness:Number):Vector.<WireFrame>
		{
			var center:Vector3D = a.add(b).add(c);
			center.scaleBy(1 / 3);
			var n:Vector3D = normal.clone();
			n.scaleBy(5);
			var list:Vector.<WireFrame> = new Vector.<WireFrame>;
			list.push(WireFrame.createLinesList(new <Vector3D>[center, center.add(n)], rgb, alpha, thickness));
			list.push(WireFrame.createLinesList(new <Vector3D>[a, b], rgb, alpha, thickness));
			list.push(WireFrame.createLinesList(new <Vector3D>[b, c], rgb, alpha, thickness));
			list.push(WireFrame.createLinesList(new <Vector3D>[c, a], rgb, alpha, thickness));
			return list;
		}
		private var center:Vector3D;
		use namespace alternativa3d;
		public function addWireToGeometry(geometry:WireGeometry):void 
		{
			if (!center) center = new Vector3D();
			center.x = (a.x + b.x + c.x) / 3;
			center.y = (a.y + b.y + c.y) / 3;
			center.z = (a.z + b.z + c.z) / 3;
			geometry.addLine(a.x, a.y, a.z, b.x, b.y, b.z);
			geometry.addLine(b.x, b.y, b.z, c.x, c.y, c.z);
			geometry.addLine(c.x, c.y, c.z, a.x, a.y, a.z);
			var nx:Number = center.x + normal.x * 5;
			var ny:Number = center.y + normal.y * 5;
			var nz:Number = center.z + normal.z * 5;
			geometry.addLine(center.x, center.y, center.z, nx, ny, nz);
		}
		*/
		
	}

}