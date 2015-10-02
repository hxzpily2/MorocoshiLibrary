package net.morocoshi.moja3d.animation 
{
	import adobe.utils.CustomActions;
	import flash.geom.Matrix3D;
	import flash.geom.Orientation3D;
	import flash.geom.Vector3D;
	import net.morocoshi.common.math.transform.AngleUtil;
	import net.morocoshi.moja3d.objects.Object3D;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class KeyframeAnimation 
	{
		/**位置、回転、スケールそれぞれに個別の直線or曲線モーションを割り当てるタイプ。*/
		static public const TYPE_CURVE:String = "curve";
		/**姿勢をMatrix3Dで決定するタイプ*/
		static public const TYPE_MATRIX:String = "matrix";
		
		static private var DEGREE:Number = 180 / Math.PI;
		
		private var capturedTransform:Object;
		private var fixRotation:Boolean;
		public var fadeRatio:Number;
			
		public var type:String;
		
		public var position:AnimationCurveNode;
		public var rotation:AnimationCurveNode;
		public var scale:AnimationCurveNode;
		public var defaultRotation:Vector3D;
		public var matrix:AnimationMatrixTrack;
		
		public var target:Object3D;
		
		public function KeyframeAnimation(type:String = TYPE_CURVE) 
		{
			this.type = type;
			fadeRatio = 1;
			capturedTransform = { };
		}
		
		public function clone():KeyframeAnimation
		{
			var result:KeyframeAnimation = new KeyframeAnimation(type);
			result.position = position? position.clone() : null;
			result.rotation = rotation? rotation.clone() : null;
			result.scale = scale? scale.clone() : null;
			result.matrix = matrix? matrix.clone() : null;
			return result;
		}
		
		/**
		 * このアニメーションを適用するObject3Dを指定する。
		 * アニメーションの無いノードのデフォルト値はこのメソッドを呼んだ時点のObject3Dのパラメータを使う。
		 * @param	object
		 */
		public function setObject(object:Object3D):void
		{
			target = object;
			if (position)
			{
				position.defaultValue.x = target.x;
				position.defaultValue.y = target.y;
				position.defaultValue.z = target.z;
			}
			if (rotation)
			{
				rotation.defaultValue.x = target.rotationX;
				rotation.defaultValue.y = target.rotationY;
				rotation.defaultValue.z = target.rotationZ;
			}
			if (scale)
			{
				scale.defaultValue.x = target.scaleX;
				scale.defaultValue.y = target.scaleY;
				scale.defaultValue.z = target.scaleZ;
			}
		}
		
		/**
		 * 強制補完タイプを設定。TangentType.NONEで無効化。
		 * @param	tangent
		 */
		public function setForceTangent(tangent:int):void
		{
			if (position) position.setForceTangent(tangent);
			if (rotation) rotation.setForceTangent(tangent);
			if (scale) scale.setForceTangent(tangent);
			if (matrix) matrix.forceTangent = tangent;
		}
		
		/**
		 * アニメーションの時間を指定する
		 * @param	time	秒
		 */
		public function setTime(time:Number):void
		{
			switch(type)
			{
				case TYPE_CURVE:
					setCurveMatrix(time);
					break;
				case TYPE_MATRIX:
					if (target)
					{
						if (fadeRatio == 1)
						{
							target.matrix = matrix.getMatrix3D(time);
						}
						else
						{
							target.matrix = Matrix3D.interpolate(capturedTransform.matrix, matrix.getMatrix3D(time), fadeRatio);
						}
					}
					break;
			}
		}
		
		public function reset():void 
		{
			if (position) position.reset();
			if (rotation) rotation.reset();
			if (scale) scale.reset();
			if (matrix) matrix.reset();
			setTime(0);
		}
		
		public function capture():void 
		{
			if (target == null) return;
			
			if (position)
			{
				capturedTransform.x = target.x;
				capturedTransform.y = target.y;
				capturedTransform.z = target.z;
			}
			if (rotation)
			{
				capturedTransform.rotationX = target.rotationX;
				capturedTransform.rotationY = target.rotationY;
				capturedTransform.rotationZ = target.rotationZ;
			}
			if (scale)
			{
				capturedTransform.scaleX = target.scaleX;
				capturedTransform.scaleY = target.scaleY;
				capturedTransform.scaleZ = target.scaleZ;
				
			}
			if (matrix)
			{
				capturedTransform.matrix = target.matrix.clone();
			}
			
			fixRotation = true;
		}
		
		private function setCurveMatrix(time:Number):void
		{
			var ratio:Number = 1 - fadeRatio;
			if (position)
			{
				var pos:Vector3D = position.getVector3D(time);
				if (fadeRatio == 1)
				{
					target.x = pos.x;
					target.y = pos.y;
					target.z = pos.z;
				}
				else
				{
					target.x = capturedTransform.x * ratio + pos.x * fadeRatio;
					target.y = capturedTransform.y * ratio + pos.y * fadeRatio;
					target.z = capturedTransform.z * ratio + pos.z * fadeRatio;
				}
			}
			if (rotation)
			{
				var rot:Vector3D = rotation.getVector3D(time);
				var radian:Number = Math.PI / 180;
				if (fadeRatio == 1)
				{
					target.rotationX = rot.x * radian;
					target.rotationY = rot.y * radian;
					target.rotationZ = rot.z * radian;
				}
				else
				{
					var rx:Number = rot.x * radian;
					var ry:Number = rot.y * radian;
					var rz:Number = rot.z * radian;
					if (fixRotation)
					{
						fixRotation = false;
						capturedTransform.rotationX = AngleUtil.toNearRadian(capturedTransform.rotationX, rx);
						capturedTransform.rotationY = AngleUtil.toNearRadian(capturedTransform.rotationY, ry);
						capturedTransform.rotationZ = AngleUtil.toNearRadian(capturedTransform.rotationZ, rz);
					}
					target.rotationX = capturedTransform.rotationX * ratio + rx * fadeRatio;
					target.rotationY = capturedTransform.rotationY * ratio + ry * fadeRatio;
					target.rotationZ = capturedTransform.rotationZ * ratio + rz * fadeRatio;
				}
			}
			if (scale)
			{
				var scl:Vector3D = scale.getVector3D(time);
				if (fadeRatio == 1)
				{
					target.scaleX = scl.x;
					target.scaleY = scl.y;
					target.scaleZ = scl.z;
				}
				else
				{
					target.scaleX = capturedTransform.scaleX * ratio + scl.x * fadeRatio;
					target.scaleY = capturedTransform.scaleY * ratio + scl.y * fadeRatio;
					target.scaleZ = capturedTransform.scaleZ * ratio + scl.z * fadeRatio;
				}
			}
		}
		/*
		private function getCurveMatrix(time:Number):Matrix3D 
		{
			var pos:Vector3D = position? position.getVector3D(time) : defaultPosition;
			var rot:Vector3D = rotation? rotation.getVector3D(time) : defaultRotation;
			var scl:Vector3D = scale? scale.getVector3D(time) : defaultScale;
			
			var mtx:Matrix3D = new Matrix3D();
			if (rot.x) mtx.appendRotation(rot.x, Vector3D.X_AXIS);
			if (rot.y) mtx.appendRotation(rot.y, Vector3D.Y_AXIS);
			if (rot.z) mtx.appendRotation(rot.z, Vector3D.Z_AXIS);
			
			mtx.appendScale(scl.x, scl.y, scl.z);
			mtx.appendTranslation(pos.x, pos.y, pos.z);
			
			return mtx;
		}
		*/
	}

}