package net.morocoshi.common.collision.solid.primitives 
{
	import flash.events.EventDispatcher;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.getQualifiedClassName;
	import net.morocoshi.common.collision.solid.Collision3DWorld;
	import net.morocoshi.common.collision.solid.events.Collision3DEvent;
	import net.morocoshi.moja3d.objects.Mesh;
	import net.morocoshi.moja3d.objects.Object3D;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class Collision3DObject extends EventDispatcher
	{
		public var name:String;
		public var skin:Object3D;
		/**所属しているコリジョンワールド（add/remove判定にも使用）*/
		public var world:Collision3DWorld;
		/**前回の位置から移動しているかどうかチェックする用*/
		private var movedTime:int;
		/**このオブジェクトが前回から動いているか*/
		private var _moved:Boolean;
		private var _x:Number;
		private var _y:Number;
		private var _z:Number;
		private var _rotationX:Number;
		private var _rotationY:Number;
		private var _rotationZ:Number;
		private var _scaleX:Number;
		private var _scaleY:Number;
		private var _scaleZ:Number;
		private var transformList:Vector.<Vector3D>;
		private var _matrix:Matrix3D;
		protected var _concatenatedMatrix:Matrix3D;
		
		/**これがtrueだと一度だけcalculate()で頂点座標などが計算される*/
		private var calculateOrder:Boolean;
		/**パラメータが変更された時にtrueになり、必要な時にmatrixが再計算される*/
		private var transformed:Boolean;
		
		private var _parent:Collision3DObject;
		private var _children:Collision3DObject;
		private var _next:Collision3DObject;
		private var _prev:Collision3DObject;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function Collision3DObject() 
		{
			name = "";
			movedTime = -1;
			calculateOrder = true;
			transformed = true;
			transformList = new Vector.<Vector3D>;
			transformList[0] = new Vector3D(0, 0, 0);//移動
			transformList[1] = new Vector3D(0, 0, 0);//回転
			transformList[2] = new Vector3D(1, 1, 1);//拡大
			_matrix = new Matrix3D();
			_concatenatedMatrix = new Matrix3D();
			_x = 0;
			_y = 0;
			_z = 0;
			_rotationX = 0;
			_rotationY = 0;
			_rotationZ = 0;
			_scaleX = 1;
			_scaleY = 1;
			_scaleZ = 1;
		}
		
		//--------------------------------------------------------------------------
		//
		//  パラメータ
		//
		//--------------------------------------------------------------------------
		
		public function set matrix(value:Matrix3D):void
		{
			var data:Vector.<Vector3D> = value.decompose();
			_x = data[0].x;
			_y = data[0].y;
			_z = data[0].z;
			_rotationX = data[1].x;
			_rotationY = data[1].y;
			_rotationZ = data[1].z;
			_scaleX = data[2].x;
			_scaleY = data[2].y;
			_scaleZ = data[2].z;
			_matrix.rawData = value.rawData;
			transformed = false;
			calculateOrder = true;
		}
		
		public function get matrix():Matrix3D 
		{
			if (transformed)
			{
				transformList[0].x = _x;
				transformList[0].y = _y;
				transformList[0].z = _z;
				transformList[1].x = _rotationX;
				transformList[1].y = _rotationY;
				transformList[1].z = _rotationZ;
				transformList[2].x = _scaleX;
				transformList[2].y = _scaleY;
				transformList[2].z = _scaleZ;
				_matrix.rawData = recompose(transformList);
				transformed = false;
			}
			return _matrix;
		}
		
		public function get rotationX():Number 
		{
			return _rotationX;
		}
		
		public function set rotationX(value:Number):void 
		{
			if (_rotationX == value) return;
			_rotationX = value;
			calculateOrder = transformed = true;
		}
		
		public function get rotationY():Number 
		{
			return _rotationY;
		}
		
		public function set rotationY(value:Number):void 
		{
			if (_rotationY == value) return;
			_rotationY = value;
			calculateOrder = transformed = true;
		}
		
		public function get rotationZ():Number 
		{
			return _rotationZ;
		}
		
		public function set rotationZ(value:Number):void 
		{
			if (_rotationZ == value) return;
			_rotationZ = value;
			calculateOrder = transformed = true;
		}
		
		public function get scaleX():Number 
		{
			return _scaleX;
		}
		
		public function set scaleX(value:Number):void 
		{
			if (_scaleX == value) return;
			_scaleX = value;
			calculateOrder = transformed = true;
		}
		
		public function get scaleY():Number 
		{
			return _scaleY;
		}
		
		public function set scaleY(value:Number):void 
		{
			if (_scaleY == value) return;
			_scaleY = value;
			calculateOrder = transformed = true;
		}
		
		public function get scaleZ():Number 
		{
			return _scaleZ;
		}
		
		public function set scaleZ(value:Number):void 
		{
			if (_scaleZ == value) return;
			_scaleZ = value;
			calculateOrder = transformed = true;
		}
		
		public function get x():Number 
		{
			return _x;
		}
		
		public function set x(value:Number):void 
		{
			if (_x == value) return;
			_x = value;
			calculateOrder = transformed = true;
		}
		
		public function get y():Number 
		{
			return _y;
		}
		
		public function set y(value:Number):void 
		{
			if (_y == value) return;
			_y = value;
			calculateOrder = transformed = true;
		}
		
		public function get z():Number 
		{
			return _z;
		}
		
		public function set z(value:Number):void 
		{
			if (_z == value) return;
			_z = value;
			calculateOrder = transformed = true;
		}
		
		/**
		 * [要継承]Meshからコリジョンデータをパースする
		 * @param	mesh
		 */
		public function parseFromMesh(mesh:Mesh):void
		{
		}
		
		//--------------------------------------------------------------------------
		//
		//  計算
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 衝突判定直前にCollision3DWorldから呼び出しておく。情報が更新されていれば必要な情報が計算される
		 */
		public function update(time:int):void
		{
			if (skin)
			{
				x = skin.x;
				y = skin.y;
				z = skin.z;
				rotationX = skin.rotationX;
				rotationY = skin.rotationY;
				rotationZ = skin.rotationZ;
				scaleX = skin.scaleX;
				scaleY = skin.scaleY;
				scaleZ = skin.scaleZ;
			}
			
			//座標計算
			if (calculateOrder)
			{
				movedTime = time;
				//親がいれば親のワールド姿勢に自分のローカル姿勢を乗算する
				if (_parent)
				{
					_concatenatedMatrix.rawData = append(matrix, _parent._concatenatedMatrix);
				}
				else
				{
					_concatenatedMatrix.copyFrom(matrix);
				}
				calculate();
			}
			_moved = movedTime == time;
			
			//子の計算
			for (var current:Collision3DObject = _children; current; current = current._next)
			{
				//親が変化していれば子も変化させる
				if (calculateOrder)
				{
					current.calculateOrder = true;
				}
				current.update(time);
			}
			
			calculateOrder = false;
		}
		
		/**
		 * 移動や回転をした時に何かを再計算する場合ここに書いておく
		 */
		protected function calculate():void
		{
		}
		
		//--------------------------------------------------------------------------
		//
		//  add/remove
		//
		//--------------------------------------------------------------------------
		
		public function get next():Collision3DObject 
		{
			return _next;
		}
		
		public function get prev():Collision3DObject 
		{
			return _prev;
		}
		
		public function get children():Collision3DObject 
		{
			return _children;
		}
		
		public function get parent():Collision3DObject 
		{
			return _parent;
		}
		
		/**
		 * このオブジェクトが持つ全ての子孫を取得
		 * @return
		 */
		public function getOffspring():Vector.<Collision3DObject>
		{
			var result:Vector.<Collision3DObject> = new <Collision3DObject>[];
			for (var current:Collision3DObject = _children; current; current = current._next)
			{
				result.push(current);
				for each(var child:Collision3DObject in current.getOffspring())
				{
					result.push(child);
				}
			}
			return result;
		}
		
		/**
		 * 子の数
		 */
		public function get numChildren():int
		{
			var count:int = 0;
			for (var current:Collision3DObject = _children; current; current = current._next)
			{
				count++;
			}
			return count;
		}
		
		/**
		 * 移動
		 */
		public function get moved():Boolean 
		{
			return _moved;
		}
		
		/**
		 * 自分を親から切り離す
		 */
		public function remove():void
		{
			if (_parent && _parent._children == this) _parent._children = _next;
			_parent = null;
			if (_next) _next._prev = _prev;
			if (_prev) _prev._next = _next;
			_prev = null;
			_next = null;
			
			if (world)
			{
				var offspring:Vector.<Collision3DObject> = getOffspring();
				offspring.push(this);
				for each (var item:Collision3DObject in offspring)
				{
					world.removeCellItem(item);
					item.world = null;
					item.dispatchEvent(new Collision3DEvent(Collision3DEvent.REMOVE_FROM_WORLD));
				}
			}
		}
		
		/**
		 * 子に追加する（リンクリストの先頭に追加）
		 * @param	object
		 * @return
		 */
		public function addChild(object:Collision3DObject):Collision3DObject 
		{
			object.remove();
			object._parent = this;
			if (_children)
			{
				_children._prev = object;
				object._next = _children;
			}
			_children = object;
			
			if (world)
			{
				var offspring:Vector.<Collision3DObject> = getOffspring();
				offspring.push(this);
				for each (var item:Collision3DObject in offspring) 
				{
					item.world = world;
					world.addCellItem(item);
					item.dispatchEvent(new Collision3DEvent(Collision3DEvent.ADD_TO_WORLD));
				}
			}
			
			return object;
		}
		
		/**
		 * 
		 * @param	name
		 * @return
		 */
		public function getChildByName(name:String):Collision3DObject 
		{
			for (var current:Collision3DObject = _children; current; current = current._next)
			{
				if (name == current.name) return current;
			}
			return null;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Matrix計算
		//
		//--------------------------------------------------------------------------
		
		private var rawData:Vector.<Number> = new Vector.<Number>(16, true);
		private function append(a:Matrix3D, b:Matrix3D):Vector.<Number>
		{
			var va:Vector.<Number> = a.rawData;
			var vb:Vector.<Number> = b.rawData;
			rawData[0]  = vb[0] * va[0]  + vb[4] * va[1]  + vb[8]  * va[2]  + vb[12] * va[3];
			rawData[1]  = vb[1] * va[0]  + vb[5] * va[1]  + vb[9]  * va[2]  + vb[13] * va[3];
			rawData[2]  = vb[2] * va[0]  + vb[6] * va[1]  + vb[10] * va[2]  + vb[14] * va[3];
			rawData[3]  = vb[3] * va[0]  + vb[7] * va[1]  + vb[11] * va[2]  + vb[15] * va[3];
			rawData[4]  = vb[0] * va[4]  + vb[4] * va[5]  + vb[8]  * va[6]  + vb[12] * va[7];
			rawData[5]  = vb[1] * va[4]  + vb[5] * va[5]  + vb[9]  * va[6]  + vb[13] * va[7];
			rawData[6]  = vb[2] * va[4]  + vb[6] * va[5]  + vb[10] * va[6]  + vb[14] * va[7];
			rawData[7]  = vb[3] * va[4]  + vb[7] * va[5]  + vb[11] * va[6]  + vb[15] * va[7];
			rawData[8]  = vb[0] * va[8]  + vb[4] * va[9]  + vb[8]  * va[10] + vb[12] * va[11];
			rawData[9]  = vb[1] * va[8]  + vb[5] * va[9]  + vb[9]  * va[10] + vb[13] * va[11];
			rawData[10] = vb[2] * va[8]  + vb[6] * va[9]  + vb[10] * va[10] + vb[14] * va[11];
			rawData[11] = vb[3] * va[8]  + vb[7] * va[9]  + vb[11] * va[10] + vb[15] * va[11];
			rawData[12] = vb[0] * va[12] + vb[4] * va[13] + vb[8]  * va[14] + vb[12] * va[15];
			rawData[13] = vb[1] * va[12] + vb[5] * va[13] + vb[9]  * va[14] + vb[13] * va[15];
			rawData[14] = vb[2] * va[12] + vb[6] * va[13] + vb[10] * va[14] + vb[14] * va[15];
			rawData[15] = vb[3] * va[12] + vb[7] * va[13] + vb[11] * va[14] + vb[15] * va[15];
			return rawData;
		}
		
		private function recompose(components:Vector.<Vector3D>):Vector.<Number>
		{
			var scale:Vector.<Number> = new Vector.<Number>(16, true);
			scale[0] = scale[1] = scale[2] = components[2].x;
			scale[4] = scale[5] = scale[6] = components[2].y;
			scale[8] = scale[9] = scale[10] = components[2].z;
			
			var cosx:Number = Math.cos(components[1].x);
			var cosy:Number = Math.cos(components[1].y);
			var cosz:Number = Math.cos(components[1].z);
			var sinx:Number = Math.sin(components[1].x);
			var siny:Number = Math.sin(components[1].y);
			var sinz:Number = Math.sin(components[1].z);
			
			rawData[0] = cosy * cosz * scale[0];
			rawData[1] = cosy * sinz * scale[1];
			rawData[2] = -siny * scale[2];
			rawData[3] = 0;
			rawData[4] = (sinx * siny * cosz - cosx * sinz) * scale[4];
			rawData[5] = (sinx * siny * sinz + cosx * cosz) * scale[5];
			rawData[6] = sinx * cosy * scale[6];
			rawData[7] = 0;
			rawData[8] = (cosx * siny * cosz + sinx * sinz) * scale[8];
			rawData[9] = (cosx * siny * sinz - sinx * cosz) * scale[9];
			rawData[10] = cosx * cosy * scale[10];
			rawData[11] = 0;
			rawData[12] = components[0].x;
			rawData[13] = components[0].y;
			rawData[14] = components[0].z;
			rawData[15] = 1;
			
			if (components[2].x == 0) rawData[0] = 1e-15;
			if (components[2].y == 0) rawData[5] = 1e-15;
			if (components[2].z == 0) rawData[10] = 1e-15;
			
			return rawData;
		}
		
		override public function toString():String 
		{
			var myName:String = (name === null)? "null" : name;
			return "[" + getQualifiedClassName(this).split("::")[1] + " " + myName + "]";
		}
		
	}

}