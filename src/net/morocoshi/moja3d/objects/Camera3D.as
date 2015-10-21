package net.morocoshi.moja3d.objects 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import net.morocoshi.common.math.transform.TransformUtil;
	import net.morocoshi.moja3d.adobe.PerspectiveMatrix3D;
	import net.morocoshi.moja3d.bounds.BoundingBox;
	import net.morocoshi.moja3d.materials.preset.FillMaterial;
	import net.morocoshi.moja3d.materials.TriangleFace;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.primitives.Sphere;
	import net.morocoshi.moja3d.view.FOVMode;
	import net.morocoshi.moja3d.view.Viewport;
	
	use namespace moja3d;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class Camera3D extends Object3D
	{
		/**垂直画角*/
		moja3d var _fovY:Number;
		/**水平画角*/
		moja3d var _fovX:Number;
		/**クリッピング距離（近）*/
		moja3d var _zNear:Number;
		/**クリッピング距離（遠）*/
		moja3d var _zFar:Number;
		/**平行投影モード*/
		moja3d var _orthographic:Boolean;
		/**平行投影時のサイズ*/
		moja3d var _width:Number;
		/**平行投影時のサイズ*/
		moja3d var _height:Number;
		
		moja3d var perspectiveMatrix:PerspectiveMatrix3D;
		moja3d var viewMatrix:Matrix3D;
		//カリング平面の法線
		moja3d var cullingNormals:Vector.<Vector3D>;
		//カリング平面の頂点
		moja3d var cullingPoints:Vector.<Vector3D>;
		/**視錐台の8頂点*/
		moja3d var frustumPoints:Vector.<Vector3D>;
		moja3d var debugPoints:Vector.<Sphere>;
		
		//カメラ平面チェック用
		private var normal:Vector3D = new Vector3D();
		private var sphere:Sphere;
		private var _aspect:Number;
		private var transformDirty:Boolean;
		private var screenWidth:Number;
		private var screenHeight:Number;
		protected var _debug:Boolean;
		private var initializedDebugPoint:Boolean;
		private var _fovMode:String = FOVMode.VERTICAL;
		
		public function Camera3D() 
		{
			_aspect = 1;
			screenWidth = -1;
			screenHeight = -1;
			transformDirty = true;
			_orthographic = false;
			_fovX = 80 / 180 * Math.PI;
			_fovY = 60 / 180 * Math.PI;
			_zNear = 0.2;
			_zFar = 10000;
			_width = 400;
			_height = 400;
			
			initializedDebugPoint = false;
			perspectiveMatrix = new PerspectiveMatrix3D();
			viewMatrix = new Matrix3D();
			cullingNormals = new Vector.<Vector3D>;
			cullingPoints = new Vector.<Vector3D>;
			frustumPoints = new Vector.<Vector3D>;
			
			var i:int;
			for (i = 0; i < 8; i++)
			{
				frustumPoints[i] = new Vector3D();
			}
			for (i = 0; i < 6; i++) 
			{
				cullingNormals[i] = new Vector3D();
				cullingPoints[i] = new Vector3D();
			}
		}
		
		public function get debug():Boolean 
		{
			return _debug;
		}
		
		public function set debug(value:Boolean):void 
		{
			_debug = value;
			if (_debug && initializedDebugPoint == false)
			{
				initDebugPoint();
			}
		}
		
		private function initDebugPoint():void 
		{
			initializedDebugPoint = true;
			debugPoints = new Vector.<Sphere>;
			
			var fillMaterial:FillMaterial = new FillMaterial(0xff0000, 1, false);
			fillMaterial.culling = TriangleFace.BOTH;
			for (var i:int = 0; i < 8; i++) 
			{
				var point:Sphere = new Sphere(1, 6, 6, fillMaterial);
				addChild(point);
				debugPoints.push(point);
			}
		}
		
		override public function clone():Object3D 
		{
			var object:Camera3D = new Camera3D();
			cloneProperties(object);
			//子を再帰的にコピーする
			for (var current:Object3D = _children; current; current = current._next)
			{
				object.addChild(current.clone());
			}
			return object;
		}
		
		override public function cloneProperties(target:Object3D):void 
		{
			super.cloneProperties(target);
			var camera:Camera3D = target as Camera3D;
			camera._aspect = _aspect;
			camera._fovX = _fovX;
			camera._fovY = _fovY;
			camera._fovMode = _fovMode;
			camera._orthographic = _orthographic;
			camera._zNear = _zNear;
			camera._zFar = _zFar;
			camera.screenWidth = screenWidth;
			camera.screenHeight = screenHeight;
		}
		
		override public function lookAt3D(point:Vector3D, upAxis:Vector3D = null):void 
		{
			TransformUtil.lookAt3D(matrix, point, "-z", "+y", upAxis, true);
			matrix = _matrix;
		}
		
		override public function lookAtXYZ(x:Number, y:Number, z:Number, upAxis:Vector3D = null):void 
		{
			TransformUtil.lookAtXYZ(matrix, x, y, z, "-z", "+y", upAxis, true);
			matrix = _matrix;
		}
		
		/**
		 * バウンディング球がこのカメラの領域内にあるかどうか
		 * @param	bounds
		 * @return
		 */
		public function contains(bounds:BoundingBox):Boolean
		{
			for (var i:int = 0; i < 6; i++) 
			{
				var p:Vector3D = cullingPoints[i];
				var n:Vector3D = cullingNormals[i];
				var dot:Number = ((bounds.worldX - p.x) * n.x) + ((bounds.worldY - p.y) * n.y) + ((bounds.worldZ - p.z) * n.z);
				if (dot < 0 && dot * dot > bounds.radius2)
				{
					return false;
				}
			}
			return true;
		}
		
		public function getDistance3D(point:Vector3D):Number
		{
			return getDistanceXYZ(point.x, point.y, point.z);
		}
		/**
		 * カメラ平面からの距離を調べる
		 * @param	px
		 * @param	py
		 * @param	pz
		 * @return
		 */
		public function getDistanceXYZ(px:Number, py:Number, pz:Number):Number 
		{
			var data:Vector.<Number> = _worldMatrix.rawData;
			
			normal.x = -data[8];
			normal.y = -data[9];
			normal.z = -data[10];
			normal.normalize();
			
			var dx:Number = px - data[12];
			var dy:Number = py - data[13];
			var dz:Number = pz - data[14];
			
			return (normal.x * dx) + (normal.y * dy) + (normal.z * dz);
		}
		
		/**
		 * デプスシャドウの範囲を計算する為に視錐台の8頂点の座標を調べる
		 * @param	near
		 * @param	far
		 */
		public function updateFrustumPoints(near:Number, far:Number):void
		{
			if (_orthographic == false)
			{
				var fov:Number = getVerticalFOV();
				var tan:Number = Math.tan(fov * 0.5);
				var n:Number = near * tan;
				var f:Number = far * tan;
				
				frustumPoints[0].z = near;
				frustumPoints[1].z = near;
				frustumPoints[2].z = near;
				frustumPoints[3].z = near;
				frustumPoints[4].z = far;
				frustumPoints[5].z = far;
				frustumPoints[6].z = far;
				frustumPoints[7].z = far;
				
				frustumPoints[0].x = n * _aspect;
				frustumPoints[0].y = -n;
				frustumPoints[1].x = -n * _aspect;
				frustumPoints[1].y = -n;
				frustumPoints[2].x = n * _aspect;
				frustumPoints[2].y = n;
				frustumPoints[3].x = -n * _aspect;
				frustumPoints[3].y = n;
				
				frustumPoints[4].x = f * _aspect;
				frustumPoints[4].y = -f;
				frustumPoints[5].x = -f * _aspect;
				frustumPoints[5].y = -f;
				frustumPoints[6].x = f * _aspect;
				frustumPoints[6].y = f;
				frustumPoints[7].x = -f * _aspect;
				frustumPoints[7].y = f;
			}
			else
			{
				frustumPoints[0].z = near;
				frustumPoints[1].z = near;
				frustumPoints[2].z = near;
				frustumPoints[3].z = near;
				frustumPoints[4].z = far;
				frustumPoints[5].z = far;
				frustumPoints[6].z = far;
				frustumPoints[7].z = far;
				
				frustumPoints[0].x = width  * 0.5;
				frustumPoints[0].y = height * -0.5;
				frustumPoints[1].x = width  * -0.5;
				frustumPoints[1].y = height * -0.5;
				frustumPoints[2].x = width  * 0.5;
				frustumPoints[2].y = height * 0.5;
				frustumPoints[3].x = width  * -0.5;
				frustumPoints[3].y = height * 0.5;
				
				frustumPoints[4].x = width  * 0.5;
				frustumPoints[4].y = height * -0.5;
				frustumPoints[5].x = width  * -0.5;
				frustumPoints[5].y = height * -0.5;
				frustumPoints[6].x = width  * 0.5;
				frustumPoints[6].y = height * 0.5;
				frustumPoints[7].x = width  * -0.5;
				frustumPoints[7].y = height * 0.5;
			}
			
			if (initializedDebugPoint)
			{
				for (var i:int = 0; i < 8; i++) 
				{
					var fp:Vector3D = frustumPoints[i];
					var dp:Sphere = debugPoints[i];
					dp.x = fp.x;
					dp.y = fp.y;
					dp.z = fp.z;
				}
			}
		}
		
		public function getVerticalFOV():Number 
		{
			var screenAsp:Number = screenWidth / screenHeight;
			var fovAsp:Number = Math.tan(_fovX / 2) / Math.tan(_fovY / 2);
			switch(_fovMode)
			{
				case FOVMode.VERTICAL:
					return _fovY;
				case FOVMode.HOLIZONTAL:
					return Math.atan((Math.tan(_fovX / 2) / screenAsp)) * 2;
				case FOVMode.INSCRIBED:
					return screenAsp > fovAsp? _fovY : Math.atan((Math.tan(_fovX / 2) / screenAsp)) * 2;
				case FOVMode.CIRCUMSCRIBED:
					return screenAsp < fovAsp? _fovY : Math.atan((Math.tan(_fovX / 2) / screenAsp)) * 2;
			}
			return _fovY;
		}
		
		/**
		 * 
		 * @param	screenWidth
		 * @param	screenHeight
		 */
		public function setScreenSize(screenWidth:Number, screenHeight:Number):void
		{
			if (screenWidth == this.screenWidth && screenHeight == this.screenHeight) return;
			
			this.screenWidth = screenWidth;
			this.screenHeight = screenHeight;
			transformDirty = true;
		}
		
		/**
		 * 
		 */
		public function checkPerspectiveUpdate():void 
		{
			///___ここは？
			//if (_orthographic) trace(this, worldMatrix.rawData);
			//if (transformDirty == false && calculateMatrixOrder == false) return;
			
			//ここでworldMatrixを最新にしてる
			calculteWorldMatrix();
			
			transformDirty = false;
			var fov:Number;
			
			_aspect = getScreenAspect();
			if (_orthographic)
			{
				perspectiveMatrix.orthoLH(_width, _height, _zNear, _zFar);
			}
			else
			{
				fov = getVerticalFOV();
				perspectiveMatrix.perspectiveFieldOfViewLH(fov, _aspect, _zNear, _zFar);
			}
			perspectiveMatrix.appendScale(-1, 1, 1);//@@@ここで座標系を変換してるけど、合ってるかあやしい
			viewMatrix.copyFrom(_worldMatrix);
			viewMatrix.appendRotation(180, getWorldAxisY(true), _worldMatrix.position);
			viewMatrix.invert();
			
			var i:int;
			var w:Number;
			var h:Number;
			var n:Number = _zNear;
			var f:Number = _zFar;
			
			if (_orthographic == false)
			{
				w = screenWidth / 2;
				h = screenHeight / 2;
				//焦点距離
				var tan:Number = 1 / Math.tan(fov * 0.5);
				
				cullingNormals[0].setTo(0, 0, -1);//near
				cullingNormals[1].setTo(0, 0, 1);//far
				cullingNormals[2].setTo(-tan, 0, -_aspect);//right
				cullingNormals[3].setTo(tan, 0, -_aspect);//left
				cullingNormals[4].setTo(0, -tan, -1);//top
				cullingNormals[5].setTo(0, tan, -1);//bottom
				
				//rltb
				for (i = 2; i < 6; i++) 
				{
					cullingPoints[i].setTo(x, y, z);
				}
				//nf
				var axis:Vector3D = getWorldAxisZ(true);
				cullingPoints[0].setTo(x - axis.x * n, y - axis.y * n, z - axis.z * n);//n
				cullingPoints[1].setTo(x - axis.x * f, y - axis.y * f, z - axis.z * f);//f
			}
			else
			{
				w = _width * 0.5;
				h = _height * 0.5;
				cullingNormals[0].setTo(0, 0, -1);//near
				cullingNormals[1].setTo(0, 0, 1);//far
				cullingNormals[2].setTo(-1, 0, 0);//right
				cullingNormals[3].setTo(1, 0, 0);//left
				cullingNormals[4].setTo(0, -1, 0);//top
				cullingNormals[5].setTo(0, 1, 0);//bottom
				
				var ax:Vector3D = getWorldAxisX(true);
				var ay:Vector3D = getWorldAxisY(true);
				var az:Vector3D = getWorldAxisZ(true);
				var data:Vector.<Number> = worldMatrix.rawData;
				
				cullingPoints[0].setTo(data[12] - az.x * n, data[13] - az.y * n, data[14] - az.z * n);//n
				cullingPoints[1].setTo(data[12] - az.x * f, data[13] - az.y * f, data[14] - az.z * f);//f
				cullingPoints[2].setTo(data[12] + ax.x * w, data[13] + ax.y * w, data[14] + ax.z * w);//r
				cullingPoints[3].setTo(data[12] - ax.x * w, data[13] - ax.y * w, data[14] - ax.z * w);//l
				cullingPoints[4].setTo(data[12] + ay.x * h, data[13] + ay.y * h, data[14] + ay.z * h);//t
				cullingPoints[5].setTo(data[12] - ay.x * h, data[13] - ay.y * h, data[14] - ay.z * h);//b
			}
			
			for (i = 0; i < 6; i++) 
			{
				TransformUtil.deltaTransformVector(cullingNormals[i], worldMatrix);
				cullingNormals[i].normalize();
			}
			
		}
		
		public function getScreenAspect():Number 
		{
			return _orthographic? _width / _height : screenWidth / screenHeight;
		}
		
		/**
		 * 指定のワールド座標をスクリーン座標に変換する
		 * @param	point	ワールド座標
		 * @param	view
		 * @return
		 */
		public function getScreenPosition(point:Vector3D, view:Viewport):Vector3D
		{
			setScreenSize(view.width, view.height);
			checkPerspectiveUpdate();
			
			var fov:Number = getVerticalFOV();
			var tanY:Number = Math.tan(fov * 0.5);
			var tanX:Number = tanY * _aspect;
			point = viewMatrix.transformVector(point);
			point.x = ( -point.x / point.z / tanX * 0.5 + 0.5) * view.width;
			point.y = ( -point.y / point.z / tanY * 0.5 + 0.5) * view.height;
			
			return point;
		}
		
		moja3d function updateFrustum():void
		{
		}
		
		public function get fovX():Number
		{
			return _fovX;
		}
		
		public function get fovY():Number 
		{
			return _fovY;
		}
		
		public function set fovX(value:Number):void
		{
			if (_fovX == value) return;
			transformDirty = true;
			
			_fovX = value;
			updateFrustum();
		}
		
		public function set fovY(value:Number):void 
		{
			if (_fovY == value) return;
			transformDirty = true;
			
			_fovY = value;
			updateFrustum();
		}
		
		public function get zNear():Number 
		{
			return _zNear;
		}
		
		public function set zNear(value:Number):void 
		{
			if (_zNear == value) return;
			transformDirty = true;
			
			_zNear = value;
			updateFrustum();
		}
		
		public function get zFar():Number 
		{
			return _zFar;
		}
		
		public function set zFar(value:Number):void 
		{
			if (_zFar == value) return;
			transformDirty = true;
			
			_zFar = value;
			updateFrustum();
		}
		
		public function get orthographic():Boolean 
		{
			return _orthographic;
		}
		
		public function set orthographic(value:Boolean):void 
		{
			if (_orthographic == value) return;
			transformDirty = true;
			
			_orthographic = value;
			updateFrustum();
		}
		
		public function get width():Number 
		{
			return _width;
		}
		
		public function set width(value:Number):void 
		{
			if (_width == value) return;
			transformDirty = true;
			
			_width = value;
			updateFrustum();
		}
		
		public function get height():Number 
		{
			return _height;
		}
		
		public function set height(value:Number):void 
		{
			if (_height == value) return;
			transformDirty = true;
			
			_height = value;
			updateFrustum();
		}
		
		public function get aspect():Number 
		{
			return _aspect;
		}
		
		/**
		 * FOVModeクラスを参照
		 */
		public function get fovMode():String 
		{
			return _fovMode;
		}
		
		public function set fovMode(value:String):void 
		{
			_fovMode = value;
		}
		
	}

}