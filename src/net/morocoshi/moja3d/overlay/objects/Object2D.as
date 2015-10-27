package net.morocoshi.moja3d.overlay.objects 
{
	import flash.display3D.Context3D;
	import flash.events.EventDispatcher;
	import flash.events.TouchEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.getQualifiedClassName;
	import net.morocoshi.common.graphics.Palette;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.objects.Object3D;
	import net.morocoshi.moja3d.overlay.mouse.OverlayTouchManager;
	import net.morocoshi.moja3d.renderer.RenderCollector;
	import net.morocoshi.moja3d.resources.Resource;
	import net.morocoshi.moja3d.shaders.render.ColorTransformShader;
	import net.morocoshi.moja3d.view.ContextProxy;
	
	use namespace moja3d;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class Object2D extends EventDispatcher
	{
		public var name:String;
		public var userData:Object;
		/**これがtrueだとこれいかの全てのオブジェクトをマスクレンダリングする*/
		public var renderMask:Boolean;
		/**最後にタッチした時のタッチID*/
		moja3d var touchID:int;
		/**スケールが反転しているかどうか1か-1*/
		moja3d var flip:int;
		
		moja3d var _screen:Screen2D;
		moja3d var _x:Number;
		moja3d var _y:Number;
		moja3d var _z:Number;
		moja3d var _rotationX:Number;
		moja3d var _rotationY:Number;
		moja3d var _rotationZ:Number;
		moja3d var _scaleX:Number;
		moja3d var _scaleY:Number;
		moja3d var _scaleZ:Number;
		moja3d var _visible:Boolean;
		moja3d var _matrix:Matrix3D;
		moja3d var _worldMatrix:Matrix3D;
		moja3d var _alpha:Number;
		private var transformList:Vector.<Vector3D>;
		private var rawData:Vector.<Number> = new Vector.<Number>(16, true);
		private var _colorTransform:ColorTransform;
		private var _worldColorTransform:ColorTransform;
		/**worldMatrix計算用に使う一時変数*/
		private var notifyChild:Object2D;
		moja3d var colorTransformShader:ColorTransformShader;
		
		/**これがtrueだとupdate()時に一度だけ色情報が計算される*/
		moja3d var calculateColorOrder:Boolean;
		/**これがtrueだと一度だけcalculate()で頂点座標などが計算される*/
		moja3d var calculateMatrixOrder:Boolean;
		/**これがtrueだと一度だけ境界領域が計算される*/
		moja3d var calculateBoundsOrder:Boolean;
		/**パラメータが変更された時にtrueになり、必要な時にxyzからmatrixが再計算される*/
		moja3d var recomposeMatrixOrder:Boolean;
		/**Matrixが変更された時にtrueになり、必要な時にxyzなどが再計算される*/
		moja3d var decomposeMatrixOrder:Boolean;
		
		moja3d var _touchable:Boolean;
		moja3d var _parent:Object2D;
		moja3d var _children:Object2D;
		moja3d var _lastChild:Object2D;
		moja3d var _next:Object2D;
		moja3d var _prev:Object2D;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function Object2D() 
		{
			name = null;
			userData = { };
			_alpha = 1;
			_visible = true;
			_touchable = true;
			flip = 1;
			
			calculateMatrixOrder = true;
			calculateColorOrder = true;
			decomposeMatrixOrder = false;
			recomposeMatrixOrder = false;
			transformList = new Vector.<Vector3D>;
			transformList[0] = new Vector3D(0, 0, 0);//移動
			transformList[1] = new Vector3D(0, 0, 0);//回転
			transformList[2] = new Vector3D(1, 1, 1);//拡大
			_matrix = new Matrix3D();
			_worldMatrix = new Matrix3D();
			_colorTransform = new ColorTransform();
			_worldColorTransform = new ColorTransform();
			colorTransformShader = new ColorTransformShader();
			
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
			_matrix.rawData = value.rawData;
			calculateMatrixOrder = true;
			recomposeMatrixOrder = false;
			decomposeMatrixOrder = false;
			decomposeMatrix();
		}
		
		public function get matrix():Matrix3D 
		{
			if (recomposeMatrixOrder)
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
				recomposeMatrixOrder = false;
			}
			return _matrix;
		}
		
		public function get rotation():Number 
		{
			if (decomposeMatrixOrder) decomposeMatrix();
			return _rotationZ;
		}
		
		public function set rotation(value:Number):void 
		{
			if (_rotationZ == value) return;
			
			_rotationZ = value;
			calculateMatrixOrder = true;
			recomposeMatrixOrder = true;
		}
		
		public function get scaleX():Number 
		{
			if (decomposeMatrixOrder) decomposeMatrix();
			return _scaleX;
		}
		
		public function set scaleX(value:Number):void 
		{
			if (_scaleX == value) return;
			
			_scaleX = value;
			calculateMatrixOrder = true;
			recomposeMatrixOrder = true;
		}
		
		public function get scaleY():Number 
		{
			if (decomposeMatrixOrder) decomposeMatrix();
			return _scaleY;
		}
		
		public function set scaleY(value:Number):void 
		{
			if (_scaleY == value) return;
			
			_scaleY = value;
			calculateMatrixOrder = true;
			recomposeMatrixOrder = true;
		}
		
		public function get x():Number 
		{
			if (decomposeMatrixOrder) decomposeMatrix();
			return _x;
		}
		
		public function set x(value:Number):void 
		{
			if (_x == value) return;
			
			_x = value;
			calculateMatrixOrder = true;
			recomposeMatrixOrder = true;
		}
		
		public function get y():Number 
		{
			if (decomposeMatrixOrder) decomposeMatrix();
			return _y;
		}
		
		public function set y(value:Number):void 
		{
			if (_y == value) return;
			
			_y = value;
			calculateMatrixOrder = true;
			recomposeMatrixOrder = true;
		}
		
		public function get alpha():Number 
		{
			return _colorTransform.alphaMultiplier;
		}
		
		public function set alpha(value:Number):void 
		{
			_colorTransform.alphaMultiplier = value;
			_colorTransform.alphaOffset = 0;
			calculateColorOrder = true;
		}
		
		//--------------------------------------------------------------------------
		//
		//  位置
		//
		//--------------------------------------------------------------------------
		
		public function setXY(x:Number, y:Number):void 
		{
			this.x = x;
			this.y = y;
		}
		
		public function setPoint(point:Point):void
		{
			x = point.x;
			y = point.y;
		}
		
		public function getPoint():Point 
		{
			return new Point(x, y);
		}
		
		//--------------------------------------------------------------------------
		//
		//  計算
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Matrix3Dを分解してxyz・・・にする
		 */
		moja3d function decomposeMatrix():void
		{
			var data:Vector.<Vector3D> = _matrix.decompose();
			_x = data[0].x;
			_y = data[0].y;
			_z = data[0].z;
			_rotationX = data[1].x;
			_rotationY = data[1].y;
			_rotationZ = data[1].z;
			_scaleX = data[2].x;
			_scaleY = data[2].y;
			_scaleZ = data[2].z;
			decomposeMatrixOrder = false;
		}
		
		/**
		 * レンダリング直前に親が変形していれば再計算する必要がある
		 * 親をたどっていき、姿勢変化しているもっとも遠い親を特定する
		 */
		public function calculteWorldMatrix():void 
		{
			var startObject:Object2D = null;
			var target:Object2D = this._parent;
			var child:Object2D = this;
			while (target)
			{
				if (target.calculateMatrixOrder)
				{
					startObject = target;
				}
				target.notifyChild = child;
				child = target;
				target = target._parent;
			}
			notifyChild = null;
			//親が変化していない場合
			if (startObject == null)
			{
				if (calculateMatrixOrder == false)
				{
					return;
				}
				if (parent == null)
				{
					_worldMatrix.copyFrom(matrix);
					return;
				}
				
				_worldMatrix.copyFrom(parent._worldMatrix);
				_worldMatrix.prepend(matrix);
				return;
			}
			
			//親が変化してる
			_worldMatrix.copyFrom(startObject._worldMatrix);
			startObject = startObject.notifyChild;
			while (startObject)
			{
				_worldMatrix.prepend(startObject.matrix);
				startObject = startObject.notifyChild;
			}
		}
		
		public function get screen():Screen2D
		{
			var current:Object2D = this;
			while (current._parent)
			{
				current = current._parent;
			}
			return current._screen;
		}
		
		//--------------------------------------------------------------------------
		//
		//  複製
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 位置、回転、スケールをコピーする
		 * @param	object
		 */
		public function copyTransformFrom(object:Object2D):void 
		{
			_x = object._x;
			_y = object._y;
			_z = object._z;
			_rotationX = object._rotationX;
			_rotationY = object._rotationY;
			_rotationZ = object._rotationZ;
			_scaleX = object._scaleX;
			_scaleY = object._scaleY;
			_scaleZ = object._scaleZ;
			calculateMatrixOrder = true;
			recomposeMatrixOrder = true;
		}
		
		public function reference():Object2D
		{
			var object:Object2D = new Object2D();
			cloneProperties(object);
			//子を再帰的にコピーする
			for (var current:Object2D = _children; current; current = current._next)
			{
				object.addChild(current.reference());
			}
			return object;
		}
		
		public function clone():Object2D
		{
			var object:Object2D = new Object2D();
			cloneProperties(object);
			//子を再帰的にコピーする
			for (var current:Object2D = _children; current; current = current._next)
			{
				object.addChild(current.clone());
			}
			return object;
		}
		
		public function referenceProperties(target:Object2D):void
		{
			target.name = name;
			target._visible = _visible;
			target.userData = userData;//___ここちゃんとコピーしたい
			target.matrix = matrix;
			target.calculateMatrixOrder = calculateMatrixOrder;
			target.decomposeMatrixOrder = decomposeMatrixOrder;
			target.recomposeMatrixOrder = recomposeMatrixOrder;
		}
		
		public function cloneProperties(target:Object2D):void
		{
			target.name = name;
			target._visible = _visible;
			target.userData = userData;//___ここちゃんとコピーしたい
			target.matrix = matrix;
			target.calculateMatrixOrder = calculateMatrixOrder;
			target.decomposeMatrixOrder = decomposeMatrixOrder;
			target.recomposeMatrixOrder = recomposeMatrixOrder;
		}
		
		/**
		 * 事前にシェーダーを生成しておく
		 * @param	hierarchy
		 */
		public function createShader(hierarchy:Boolean):void 
		{
			if (hierarchy)
			{
				//子を再帰的に
				for (var current:Object2D = _children; current; current = current._next)
				{
					current.createShader(hierarchy);
				}
			}
		}
		
		public function getResources(hierarchy:Boolean, classObject:Class = null):Vector.<Resource> 
		{
			var result:Vector.<Resource> = new Vector.<Resource>;
			if (hierarchy)
			{
				//子を再帰的に
				for (var current:Object2D = _children; current; current = current._next)
				{
					result = result.concat(current.getResources(hierarchy, classObject));
				}
			}
			return result;
		}
		
		/**
		 * 必要素材をContext3Dに転送する
		 * @param	context3D
		 */
		public function upload(context3D:ContextProxy, hierarchy:Boolean, async:Boolean, complete:Function = null):void 
		{
			var list:Vector.<Resource> = getResources(hierarchy);
			var n:int = list.length;
			for (var i:int = 0; i < n; i++)
			{
				var resource:Resource = list[i];
				resource.upload(context3D, async, complete);
			}
		}
		
		/**
		 * アップロードした素材をすべて破棄する
		 * @param	context3D
		 * @param	hierarchy
		 */
		public function dispose(hierarchy:Boolean):void 
		{
			if (hierarchy)
			{
				//子を再帰的に
				for (var current:Object2D = _children; current; current = current._next)
				{
					current.dispose(hierarchy);
				}
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  視線
		//
		//--------------------------------------------------------------------------
		
		//--------------------------------------------------------------------------
		//
		//  計算
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 描画データを収集する
		 * @param	renderer
		 */
		moja3d function collectRenderElements(collector:RenderCollector, forceCalcMatrix:Boolean, forceCalcColor:Boolean, worldFlip:int):Boolean
		{
			var phase:String = collector.renderPhase;
			
			var calcMatrix:Boolean = calculateMatrixOrder || forceCalcMatrix;
			var calcColor:Boolean = calculateColorOrder || forceCalcColor;
			
			//色合成
			if (calcColor)
			{
				//親がいれば親のワールド色に自分のローカル色を乗算する
				if (_parent)
				{
					Palette.copyTo(_worldColorTransform, _parent._worldColorTransform);
					_worldColorTransform.concat(_colorTransform);
				}
				else
				{
					Palette.copyTo(_worldColorTransform, _colorTransform);
				}
				
				colorTransformShader.applyFrom(_worldColorTransform);
				
				calculateColorOrder = false;
			}
			
			//座標計算
			if (calcMatrix)
			{
				collector._moveCount++;
				//親がいれば親のワールド姿勢に自分のローカル姿勢を乗算する
				if (_parent)
				{
					_worldMatrix.rawData = append(matrix, _parent._worldMatrix);
				}
				else
				{
					_worldMatrix.copyFrom(matrix);
				}
				
				calculate();
				calculateMatrixOrder = false;
				
				//XYZスケールがマイナスかどうかチェックし、最終スケールがマイナスなら表示を反転する
				var rx:int = (scaleX >= 0)? 1 : -1;
				var ry:int = (scaleY >= 0)? 1 : -1;
				flip = (rx * ry);
			}
			
			//子を再帰的に収集する
			for (var current:Object2D = _lastChild; current; current = current._prev)
			{
				//非表示の子は計算はしないが、親が姿勢変化していた場合は通知しておく
				if (current._visible == false)
				{
					current.calculateMatrixOrder = (current.calculateMatrixOrder || calcMatrix);
					continue;
				}
				current.collectRenderElements(collector, calcMatrix, calcColor, worldFlip * flip);
			}
			
			return true;
		}
		
		moja3d function hitTestTouchEvent(touch:OverlayTouchManager, forceCalcMatrix:Boolean):Boolean
		{
			var calcMatrix:Boolean = calculateMatrixOrder || forceCalcMatrix;
			
			//座標計算
			if (calcMatrix)
			{
				//親がいれば親のワールド姿勢に自分のローカル姿勢を乗算する
				if (_parent)
				{
					_worldMatrix.rawData = append(matrix, _parent._worldMatrix);
				}
				else
				{
					_worldMatrix.copyFrom(matrix);
				}
				
				calculate();
				calculateMatrixOrder = false;
			}
			
			//子を再帰的に収集する
			for (var current:Object2D = _lastChild; current; current = current._prev)
			{
				//非表示の子は計算はしないが、親が姿勢変化していた場合は通知しておく
				//___これだとルートを非表示などにできない？
				if (current._visible == false || current._touchable == false)
				{
					current.calculateMatrixOrder = (current.calculateMatrixOrder || calcMatrix);
					continue;
				}
				if (current.hitTestTouchEvent(touch, calcMatrix))
				{
					return true;
				}
			}
			
			return false;
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
		
		public function get next():Object2D 
		{
			return _next;
		}
		
		public function get prev():Object2D 
		{
			return _prev;
		}
		
		public function get children():Object2D 
		{
			return _children;
		}
		
		public function get parent():Object2D 
		{
			return _parent;
		}
		
		/**
		 * このオブジェクトが持つ全ての子孫を取得(重いので注意)
		 * @return
		 */
		public function getOffspring():Vector.<Object2D>
		{
			var result:Vector.<Object2D> = new <Object2D>[];
			for (var current:Object2D = _children; current; current = current._next)
			{
				result.push(current);
				var offspring:Vector.<Object2D> = current.getOffspring();
				var n:int = offspring.length;
				for (var i:int = 0; i < n; i++)
				{
					var child:Object2D = offspring[i];
					result.push(child);
				}
			}
			return result;
		}
		
		/**
		 * 子の数（毎回ループで計算します）
		 */
		public function get numChildren():int
		{
			var count:int = 0;
			for (var current:Object2D = _children; current; current = current._next)
			{
				count++;
			}
			return count;
		}
		
		/**
		 * ワールド姿勢
		 */
		public function get worldMatrix():Matrix3D 
		{
			calculteWorldMatrix();
			return _worldMatrix;
		}
		
		/**
		 * 表示状況
		 */
		public function get visible():Boolean 
		{
			return _visible;
		}
		
		public function set visible(value:Boolean):void 
		{
			if (_visible == value) return;
			
			_visible = value;
		}
		
		public function get touchable():Boolean 
		{
			return _touchable;
		}
		
		public function set touchable(value:Boolean):void 
		{
			_touchable = value;
		}
		
		/**
		 * 自分を親から切り離す
		 */
		public function remove():void
		{
			if (_parent && _parent._children == this) _parent._children = _next;
			if (_parent && _parent._lastChild == this) _parent._lastChild = _prev;
			_parent = null;
			if (_next) _next._prev = _prev;
			if (_prev) _prev._next = _next;
			_prev = null;
			_next = null;
		}
		
		/**
		 * 子に追加する（リンクリストの先頭に追加）
		 * @param	object
		 * @return
		 */
		public function addChild(object:Object2D):Object2D 
		{
			if (object == null)
			{
				throw new Error("addChild（）しようとしたObject3Dがnullになっています。");
			}
			object.remove();
			object._parent = this;
			if (_children == null)
			{
				_children = object;
			}
			if (_lastChild)
			{
				_lastChild._next = object;
				object._prev = _lastChild;
			}
			_lastChild = object;
			return object;
		}
		
		public function getChildAt(num:int):Object2D 
		{
			var count:int = -1;
			for (var current:Object2D = _children; current; current = current._next)
			{
				count++;
				if (num == count) return current;
			}
			return null;
		}
		
		/**
		 * 
		 * @param	name
		 * @param	hierarchy
		 * @return
		 */
		public function getChildByName(name:String, hierarchy:Boolean = false):Object2D 
		{
			for (var current:Object2D = _children; current; current = current._next)
			{
				if (name == current.name)
				{
					return current;
				}
				if (hierarchy)
				{
					var result:Object2D = current.getChildByName(name, hierarchy);
					if (result) return result;
				}
			}
			
			return null;
		}
		
		/**
		 * XYのスケールを一括で設定
		 * @param	scale
		 */
		public function setScaleXY(x:Number, y:Number):void 
		{
			scaleX = x;
			scaleY = y;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Matrix計算
		//
		//--------------------------------------------------------------------------
		
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