package net.morocoshi.moja3d.objects 
{
	import flash.display3D.Context3D;
	import flash.events.EventDispatcher;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.getQualifiedClassName;
	import net.morocoshi.common.graphics.Palette;
	import net.morocoshi.common.math.list.VectorUtil;
	import net.morocoshi.common.math.transform.TransformUtil;
	import net.morocoshi.moja3d.bounds.BoundingBox;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.renderer.RenderCollector;
	import net.morocoshi.moja3d.renderer.RenderPhase;
	import net.morocoshi.moja3d.resources.Resource;
	import net.morocoshi.moja3d.resources.ResourceUploader;
	import net.morocoshi.moja3d.shaders.render.ColorTransformShader;
	
	use namespace moja3d;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class Object3D extends EventDispatcher
	{
		public var name:String;
		public var animationID:String;
		public var userData:Object;
		/**反射用レンダリング時に除外するか*/
		public var ignoreReflect:Boolean;
		/**このオブジェクトが影を落とすか*/
		public var castShadow:Boolean;
		public var castLight:Boolean;
		/**これが0以外だと自分以下の子オブジェクトをマスクレンダリングする。MaskColorクラス参照。*/
		public var renderMask:uint;
		/**正の値ほど後ろにまわる*/
		public var sortPriority:Number;
		//public var boundingSphere:BoundingSphere;
		public var boundingBox:BoundingBox;
		private var _fitOnCamera:Boolean;
		
		private var _colorTransform:ColorTransform;
		moja3d var worldColorTransform:ColorTransform;
		moja3d var colorTransformShader:ColorTransformShader;
		
		/**スケールが反転しているかどうか1か-1*/
		moja3d var flip:int;
		
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
		/**worldMatrix計算用に使う一時変数*/
		private var notifyChild:Object3D;
		
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
		
		moja3d var _parent:Object3D;
		moja3d var _children:Object3D;
		moja3d var _lastChild:Object3D;
		moja3d var _next:Object3D;
		moja3d var _prev:Object3D;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function Object3D() 
		{
			name = null;
			userData = { };
			boundingBox = null;
			_alpha = 1;
			sortPriority = 0;
			_visible = true;
			flip = 1;
			
			castShadow = true;
			castLight = true;
			ignoreReflect = false;
			renderMask = 0x0;
			calculateMatrixOrder = true;
			calculateColorOrder = true;
			calculateBoundsOrder = true;
			decomposeMatrixOrder = false;
			recomposeMatrixOrder = false;
			transformList = new Vector.<Vector3D>;
			transformList[0] = new Vector3D(0, 0, 0);//移動
			transformList[1] = new Vector3D(0, 0, 0);//回転
			transformList[2] = new Vector3D(1, 1, 1);//拡大
			_matrix = new Matrix3D();
			_worldMatrix = new Matrix3D();
			
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
			calculateBoundsOrder = true;
			recomposeMatrixOrder = false;
			decomposeMatrixOrder = false;
			decomposeMatrix();
		}
		
		/**
		 * 内部変数をそのまま返すので弄るときはcloneしてから！
		 */
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
		
		public function get rotationX():Number 
		{
			if (decomposeMatrixOrder) decomposeMatrix();
			return _rotationX;
		}
		
		public function set rotationX(value:Number):void 
		{
			if (_rotationX == value) return;
			
			_rotationX = value;
			calculateMatrixOrder = true;
			calculateBoundsOrder = true;
			recomposeMatrixOrder = true;
		}
		
		public function get rotationY():Number 
		{
			if (decomposeMatrixOrder) decomposeMatrix();
			return _rotationY;
		}
		
		public function set rotationY(value:Number):void 
		{
			if (_rotationY == value) return;
			
			_rotationY = value;
			calculateMatrixOrder = true;
			calculateBoundsOrder = true;
			recomposeMatrixOrder = true;
		}
		
		public function get rotationZ():Number 
		{
			if (decomposeMatrixOrder) decomposeMatrix();
			return _rotationZ;
		}
		
		public function set rotationZ(value:Number):void 
		{
			if (_rotationZ == value) return;
			
			_rotationZ = value;
			calculateMatrixOrder = true;
			calculateBoundsOrder = true;
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
			calculateBoundsOrder = true;
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
			calculateBoundsOrder = true;
			calculateMatrixOrder = true;
			recomposeMatrixOrder = true;
		}
		
		public function get scaleZ():Number 
		{
			if (decomposeMatrixOrder) decomposeMatrix();
			return _scaleZ;
		}
		
		public function set scaleZ(value:Number):void 
		{
			if (_scaleZ == value) return;
			
			_scaleZ = value;
			calculateBoundsOrder = true;
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
		
		public function get z():Number 
		{
			if (decomposeMatrixOrder) decomposeMatrix();
			return _z;
		}
		
		public function set z(value:Number):void 
		{
			if (_z == value) return;
			
			_z = value;
			calculateMatrixOrder = true;
			recomposeMatrixOrder = true;
		}
		
		public function get alpha():Number 
		{
			return _alpha;
		}
		
		public function set alpha(value:Number):void 
		{
			_alpha = value;
			calculateColorOrder = true;
			if (_colorTransform == null)
			{
				_colorTransform = new ColorTransform();
			}
			_colorTransform.alphaMultiplier = value;
			_colorTransform.alphaOffset = 0;
		}
		
		//--------------------------------------------------------------------------
		//
		//  位置
		//
		//--------------------------------------------------------------------------
		
		public function setPositionXYZ(x:Number, y:Number, z:Number):void 
		{
			this.x = x;
			this.y = y;
			this.z = z;
		}
		
		public function setPosition3D(point:Vector3D):void
		{
			x = point.x;
			y = point.y;
			z = point.z;
		}
		
		public function getWorldPosition():Vector3D
		{
			var point:Vector3D = new Vector3D(x, y, z);
			return parent? parent.worldMatrix.transformVector(point) : point;
		}
		
		public function getPosition():Vector3D 
		{
			return new Vector3D(x, y, z);
		}
		
		//--------------------------------------------------------------------------
		//
		//  計算
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 境界ボックスを包む境界球を計算するための下準備をする。このメソッドはMeshでoverrideしています。
		 */
		public function calculateBounds():void
		{
		}
		
		/**
		 * Matrix3Dを分解してxyz～にする
		 */
		private function decomposeMatrix():void
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
		 * レンダリング直前に親が変形していれば再計算する必要がある。親をたどっていき、姿勢変化しているもっとも遠い親を特定する。
		 */
		public function calculteWorldMatrix():void 
		{
			var startObject:Object3D = null;
			var target:Object3D = this._parent;
			var child:Object3D = this;
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
		
		//--------------------------------------------------------------------------
		//
		//  複製
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 位置、回転、スケールをコピーする
		 * @param	object
		 */
		public function copyTransformFrom(object:Object3D):void 
		{
			x = object.x;
			y = object.y;
			z = object.z;
			rotationX = object.rotationX;
			rotationY = object.rotationY;
			rotationZ = object.rotationZ;
			scaleX = object.scaleX;
			scaleY = object.scaleY;
			scaleZ = object.scaleZ;
		}
		
		public function reference():Object3D
		{
			var object:Object3D = new Object3D();
			referenceProperties(object);
			//子を再帰的にコピーする
			for (var current:Object3D = _children; current; current = current._next)
			{
				object.addChild(current.reference());
			}
			return object;
		}
		
		public function clone():Object3D
		{
			var object:Object3D = new Object3D();
			cloneProperties(object);
			//子を再帰的にコピーする
			for (var current:Object3D = _children; current; current = current._next)
			{
				object.addChild(current.clone());
			}
			return object;
		}
		
		public function referenceProperties(target:Object3D):void
		{
			target.name = name;
			target.animationID = animationID;
			target._visible = _visible;
			target._colorTransform = _colorTransform? Palette.clone(_colorTransform) : null;
			target.castShadow = castShadow;
			target.castLight = castLight;
			target.ignoreReflect = ignoreReflect;
			target.renderMask = renderMask;
			target.userData = userData;//@@@ここちゃんとコピーしたい
			target.matrix = matrix;
			target._worldMatrix.copyFrom(_worldMatrix);
			target.calculateColorOrder = calculateColorOrder;
			target.calculateMatrixOrder = calculateMatrixOrder;
			target.calculateBoundsOrder = calculateBoundsOrder;
			target.decomposeMatrixOrder = decomposeMatrixOrder;
			target.recomposeMatrixOrder = recomposeMatrixOrder;
			if (boundingBox)
			{
				target.boundingBox = boundingBox.clone();
			}
		}
		
		public function cloneProperties(target:Object3D):void
		{
			target.name = name;
			target.animationID = animationID;
			target._visible = _visible;
			target._colorTransform = _colorTransform? Palette.clone(_colorTransform) : null;
			target.castShadow = castShadow;
			target.castLight = castLight;
			target.ignoreReflect = ignoreReflect;
			target.renderMask = renderMask;
			target.userData = userData;//@@@ここちゃんとコピーしたい
			target.matrix = matrix;
			target._worldMatrix.copyFrom(_worldMatrix);
			target.calculateColorOrder = calculateColorOrder;
			target.calculateMatrixOrder = calculateMatrixOrder;
			target.calculateBoundsOrder = calculateBoundsOrder;
			target.decomposeMatrixOrder = decomposeMatrixOrder;
			target.recomposeMatrixOrder = recomposeMatrixOrder;
			if (boundingBox)
			{
				target.boundingBox = boundingBox.clone();
			}
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
				for (var current:Object3D = _children; current; current = current._next)
				{
					current.createShader(hierarchy);
				}
			}
		}
		
		/**
		 * 
		 * @param	hierarchy
		 * @param	filter
		 * @return
		 */
		public function getResources(hierarchy:Boolean, filter:Class = null):Vector.<Resource> 
		{
			var result:Vector.<Resource> = new Vector.<Resource>;
			if (hierarchy)
			{
				//子を再帰的に
				for (var current:Object3D = _children; current; current = current._next)
				{
					result = result.concat(current.getResources(hierarchy, filter));
				}
			}
			return result;
		}
		
		/**
		 * 必要素材をContext3Dに転送する
		 * @param	context3D	upload先
		 * @param	hierarchy	子以下もuploadするか
		 * @param	async	非同期でuploadするか
		 * @param	complete	非同期uploadする場合の完了イベント
		 */
		public function upload(context3D:Context3D, hierarchy:Boolean, async:Boolean, complete:Function = null):void 
		{
			new ResourceUploader().upload(context3D, getResources(hierarchy), async, complete);
		}
		
		/**
		 * このオブジェクトが生成する予定のProgram3Dを事前に生成しておく
		 * @param	context3D
		 * @param	hierarchy
		 */
		public function preloadPrograms(context3D:Context3D, hierarchy:Boolean):void 
		{
			var collector:RenderCollector = new RenderCollector();
			collector.context3D = context3D;
			collector.renderPhase = RenderPhase.CHECK;
			collector.renderElementList = { };
			collectRenderElements(collector, false, false, false, 1, 0);
			if (collector.reflectiveWater.hasReflectElement)
			{
				collector.renderPhase = RenderPhase.REFLECT;
				collectRenderElements(collector, false, false, false, 1, 0);
			}
			collector.renderPhase = RenderPhase.NORMAL;
			collectRenderElements(collector, false, false, false, 1, 0);
		}
		
		/**
		 * アップロードした素材をすべて破棄する
		 * @param	hierarchy
		 */
		public function dispose(hierarchy:Boolean):void 
		{
			if (hierarchy)
			{
				//子を再帰的に
				for (var current:Object3D = _children; current; current = current._next)
				{
					current.dispose(hierarchy);
				}
			}
		}
		
		public function removeChildren():void
		{
			var child:Object3D = _children;
			while (child)
			{
				child.remove();
				child = child._next;
			}
		}
		
		public function disposeChildren():void
		{
			var child:Object3D = _children;
			while (child)
			{
				child.dispose(true);
				child = child._next;
			}
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  視線
		//
		//--------------------------------------------------------------------------
		
		public function getWorldAxisX(normalized:Boolean):Vector3D
		{
			var rawData:Vector.<Number> = worldMatrix.rawData;
			var look:Vector3D = new Vector3D(rawData[0], rawData[1], rawData[2]);
			if (normalized)
			{
				look.normalize();
			}
			return look;
		}
		
		public function getWorldAxisY(normalized:Boolean):Vector3D
		{
			var rawData:Vector.<Number> = worldMatrix.rawData;
			var look:Vector3D = new Vector3D(rawData[4], rawData[5], rawData[6]);
			if (normalized)
			{
				look.normalize();
			}
			return look;
		}
		
		public function getWorldAxisZ(normalized:Boolean):Vector3D
		{
			var rawData:Vector.<Number> = worldMatrix.rawData;
			var look:Vector3D = new Vector3D(rawData[8], rawData[9], rawData[10]);
			if (normalized)
			{
				look.normalize();
			}
			return look;
		}
		
		public function getLocalAxisX(normalized:Boolean):Vector3D
		{
			var rawData:Vector.<Number> = matrix.rawData;
			var look:Vector3D = new Vector3D(rawData[0], rawData[1], rawData[2]);
			if (normalized)
			{
				look.normalize();
			}
			return look;
		}
		
		public function getLocalAxisY(normalized:Boolean):Vector3D
		{
			var rawData:Vector.<Number> = matrix.rawData;
			var look:Vector3D = new Vector3D(rawData[4], rawData[5], rawData[6]);
			if (normalized)
			{
				look.normalize();
			}
			return look;
		}
		
		public function getLocalAxisZ(normalized:Boolean):Vector3D
		{
			var rawData:Vector.<Number> = matrix.rawData;
			var look:Vector3D = new Vector3D(rawData[8], rawData[9], rawData[10]);
			if (normalized)
			{
				look.normalize();
			}
			return look;
		}
		
		/**
		 * オブジェクトごとに最適な方向でlookAtする。Object3DはY軸マイナス、カメラはZ軸プラスなど
		 * @param	point
		 * @param	upAxis
		 */
		public function lookAt3D(point:Vector3D, upAxis:Vector3D = null):void
		{
			TransformUtil.lookAt3D(matrix, point, "-y", "+z", upAxis, true);
			matrix = _matrix;
		}
		
		/**
		 * オブジェクトごとに最適な方向でlookAtする。Object3DはY軸マイナス、カメラはZ軸プラスなど
		 * @param	x
		 * @param	y
		 * @param	z
		 * @param	upAxis
		 */
		public function lookAtXYZ(x:Number, y:Number, z:Number, upAxis:Vector3D = null):void
		{
			TransformUtil.lookAtXYZ(matrix, x, y, z, "-y", "+z", upAxis, true);
			matrix = _matrix;
		}
		
		public function lookAtAxis3D(point:Vector3D, frontAxis:String, topAxis:String, upAxis:Vector3D = null):void
		{
			TransformUtil.lookAt3D(matrix, point, frontAxis, topAxis, upAxis, true);
			matrix = _matrix;
		}
		
		public function lookAtAxisXYZ(x:Number, y:Number, z:Number, frontAxis:String, topAxis:String, upAxis:Vector3D = null):void
		{
			TransformUtil.lookAtXYZ(matrix, x, y, z, frontAxis, topAxis, upAxis, true);
			matrix = _matrix;
		}
		
		//--------------------------------------------------------------------------
		//
		//  計算
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 描画データを収集する
		 * @param	collector
		 * @param	forceCalcMatrix
		 * @param	forceCalcColor
		 * @param	forceCalcBounds
		 * @param	worldFlip
		 * @param	mask
		 * @return
		 */
		moja3d function collectRenderElements(collector:RenderCollector, forceCalcMatrix:Boolean, forceCalcColor:Boolean, forceCalcBounds:Boolean, worldFlip:int, mask:uint):Boolean
		{
			var phase:String = collector.renderPhase;
			
			//Z深度レンダリング時に除外する場合
			if (phase == RenderPhase.DEPTH && castShadow == false)
			{
				return false;
			}
			
			//Z深度レンダリング時に除外する場合
			if (phase == RenderPhase.LIGHT && castLight == false)
			{
				return false;
			}
			
			//反射レンダリング時に除外する場合
			if (phase == RenderPhase.REFLECT && ignoreReflect)
			{
				return false;
			}
			
			var calcMatrix:Boolean = calculateMatrixOrder || forceCalcMatrix;
			var calcColor:Boolean = calculateColorOrder || forceCalcColor;
			var calcBounds:Boolean = calculateBoundsOrder || forceCalcBounds;
			
			//マスクが設定されていれば全ての子をマスク扱いにする
			mask |= renderMask;
			
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
				
				if (boundingBox)
				{
					boundingBox.transformByMatrix(_worldMatrix, calcBounds);
				}
				calculate();
				calculateMatrixOrder = false;
				
				//XYZスケールがマイナスかどうかチェックし、最終スケールがマイナスなら表示を反転する
				var rx:int = (scaleX >= 0)? 1 : -1;
				var ry:int = (scaleY >= 0)? 1 : -1;
				var rz:int = (scaleZ >= 0)? 1 : -1;
				flip = (rx * ry * rz);
			}
			
			//色計算
			if (calcColor)
			{
				collector._colorCount++;
				
				if (colorTransformShader == null) colorTransformShader = new ColorTransformShader();
				//if (_colorTransform == null) _colorTransform = new ColorTransform();
				if (worldColorTransform == null) worldColorTransform = new ColorTransform();
				
				if (_parent)
				{
					Palette.copyTo(worldColorTransform, _parent.worldColorTransform);
					if (_colorTransform)
					{
						worldColorTransform.concat(_colorTransform);
					}
				}
				else
				{
					if (_colorTransform)
					{
						Palette.copyTo(worldColorTransform, _colorTransform);
					}
					else
					{
						Palette.identity(worldColorTransform);
					}
				}
				colorTransformShader.applyFrom(worldColorTransform);
				
				calculateColorOrder = false;
			}
			
			//子を再帰的に収集する
			for (var current:Object3D = _children; current; current = current._next)
			{
				//非表示の子は計算はしないが、親が姿勢変化していた場合は通知しておく
				if (current._visible == false)
				{
					current.calculateMatrixOrder = (current.calculateMatrixOrder || calcMatrix);
					continue;
				}
				current.collectRenderElements(collector, calcMatrix, calcColor, calcBounds, worldFlip * flip, mask);
			}
			
			//境界球で除外
			_fitOnCamera = !(boundingBox && collector.camera && collector.camera.contains(boundingBox) == false);
			return _fitOnCamera;
		}
		
		/**
		 * 移動や回転をした時に何かを再計算する場合に使用（ボーンとスキンでも使う）
		 */
		protected function calculate():void 
		{
			
		}
		
		//--------------------------------------------------------------------------
		//
		//  add/remove
		//
		//--------------------------------------------------------------------------
		
		public function get next():Object3D 
		{
			return _next;
		}
		
		public function get prev():Object3D 
		{
			return _prev;
		}
		
		public function get children():Object3D 
		{
			return _children;
		}
		
		public function get parent():Object3D 
		{
			return _parent;
		}
		
		/**
		 * 子の数（毎回ループで計算するので注意）
		 */
		public function get numChildren():int
		{
			var count:int = 0;
			for (var current:Object3D = _children; current; current = current._next)
			{
				count++;
			}
			return count;
		}
		
		/**
		 * 最新のワールド姿勢を取得する。必要なら再計算がされる。このMatrix3Dを直接弄ると内部に影響するので注意。
		 */
		public function get worldMatrix():Matrix3D 
		{
			calculteWorldMatrix();
			return _worldMatrix;
			/*
			 * これは負荷の高い元の正確なコード。calculteWorldMatrixにミスがなければ削除していい
			var target:Object3D = this._parent;
			var m3d:Matrix3D = matrix.clone();
			while (target)
			{
				m3d.prepend(target.matrix);
				target = target._parent;
			}
			_worldMatrix = m3d;
			
			return _worldMatrix;
			*/
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
		
		/**
		 * 着色設定をColorTransformで指定
		 */
		public function get colorTransform():ColorTransform 
		{
			return _colorTransform;
		}
		
		public function set colorTransform(value:ColorTransform):void 
		{
			_colorTransform = value;
			calculateColorOrder = true;
		}
		
		/**
		 * 前回の描画時にオブジェクトの境界球がカメラの視野内に収まっていたかどうか
		 */
		public function get fitOnCamera():Boolean 
		{
			return _fitOnCamera;
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
		public function addChild(object:Object3D):Object3D 
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
		
		/**
		 * インデックスの位置の子を取得
		 * @param	num
		 * @return
		 */
		public function getChildAt(num:int):Object3D 
		{
			var count:int = -1;
			for (var current:Object3D = _children; current; current = current._next)
			{
				count++;
				if (num == count) return current;
			}
			return null;
		}
		
		/**
		 * 名前が一致する子を1つだけ取得
		 * @param	name
		 * @param	hierarchy
		 * @return
		 */
		public function getChildByName(name:String, hierarchy:Boolean = false):Object3D 
		{
			for (var current:Object3D = _children; current; current = current._next)
			{
				if (name == current.name)
				{
					return current;
				}
				if (hierarchy)
				{
					var result:Object3D = current.getChildByName(name, hierarchy);
					if (result) return result;
				}
			}
			
			return null;
		}
		
		
		/**
		 * アニメーションIDが一致する子を取得
		 * @param	key
		 * @param	boolean
		 */
		public function getChildByAnimationID(id:String, hierarchy:Boolean = true):Object3D 
		{
			for (var current:Object3D = _children; current; current = current._next)
			{
				if (id == current.animationID)
				{
					return current;
				}
				if (hierarchy)
				{
					var result:Object3D = current.getChildByAnimationID(id, hierarchy);
					if (result) return result;
				}
			}
			
			return null;
		}
		
		/**
		 * 名前が一致する子を配列で取得
		 * @param	name
		 * @param	hierarchy
		 * @return
		 */
		public function getChildrenByName(name:String, hierarchy:Boolean):Vector.<Object3D> 
		{
			var result:Vector.<Object3D> = new Vector.<Object3D>;
			for (var current:Object3D = _children; current; current = current._next)
			{
				if (name == current.name)
				{
					result.push(current);
				}
				if (hierarchy)
				{
					VectorUtil.attachListDiff(result, current.getChildrenByName(name, hierarchy));
				}
			}
			
			return result;
		}
		
		/**
		 * このオブジェクトが持つ全ての子を取得
		 * @param	addThis
		 * @param	hierarchy
		 * @param	filter
		 * @return
		 */
		public function getChildren(addThis:Boolean, hierarchy:Boolean, filter:Class = null):Vector.<Object3D>
		{
			if (filter == null) filter = Object3D;
			
			var result:Vector.<Object3D> = new <Object3D>[];
			
			for (var current:Object3D = _children; current; current = current._next)
			{
				if (current is filter)
				{
					result.push(current);
				}
				if (current._children == null || hierarchy == false)
				{
					continue;
				}
				
				var currentChildren:Vector.<Object3D> = current.getChildren(false, hierarchy, filter);
				var n:int = currentChildren.length;
				for (var i:int = 0; i < n; i++) 
				{
					var child:Object3D = currentChildren[i];
					if (child is filter)
					{
						result.push(child);
					}
				}
			}
			
			if (addThis && this is filter)
			{
				result.push(this);
			}
			
			return result;
		}
				
		/**
		 * XYZのスケールを一括で設定
		 * @param	scale
		 */
		public function setScale(scale:Number):void 
		{
			scaleX = scaleY = scaleZ = scale;
		}
		
		/**
		 * スケールをXYZで設定
		 * @param	x
		 * @param	y
		 * @param	z
		 */
		public function setScaleXYZ(x:Number, y:Number, z:Number):void 
		{
			scaleX = x;
			scaleY = y;
			scaleZ = z;
		}
		
		/**
		 * スケールをVector3Dで設定
		 * @param	point
		 */
		public function setScale3D(point:Vector3D):void 
		{
			scaleX = point.x;
			scaleY = point.y;
			scaleZ = point.z;
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
		
		public function intersectRay(start:Vector3D, end:Vector3D, infinity:Boolean):void 
		{
		}
		
	}

}