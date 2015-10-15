package net.morocoshi.moja3d.animation 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import net.morocoshi.common.math.transform.AngleUtil;
	import net.morocoshi.moja3d.objects.Object3D;
	import net.morocoshi.moja3d.shaders.render.UVOffsetShader;
	
	/**
	 * 1つのオブジェクトを動かすキーフレームアニメーション
	 * 
	 * @author tencho
	 */
	public class KeyframeAnimation 
	{
		/**位置、回転、スケールそれぞれに個別の直線or曲線モーションを割り当てるタイプ。*/
		static public const TYPE_CURVE:String = "curve";
		/**姿勢をMatrix3Dで決定するタイプ*/
		static public const TYPE_MATRIX:String = "matrix";
		/**アニメーション情報のないノード用*/
		static public const TYPE_MOTIONLESS_MATRIX:String = "motionlessMatrix";
		/**マテリアルのUVオフセットを動かすタイプ*/
		static public const TYPE_MATERIAL:String = "material";
		
		static private var DEGREE:Number = 180 / Math.PI;
		
		public var type:String;
		
		/**モーションブレンドの割合*/
		public var blendRatio:Number;
		/**UVオフセットシェーダー*/
		public var uvOffsetShader:UVOffsetShader;
		public var material:AnimationMaterialNode;
		public var position:AnimationCurveNode;
		public var rotation:AnimationCurveNode;
		public var scale:AnimationCurveNode;
		public var defaultRotation:Vector3D;
		public var matrix:AnimationMatrixTrack;
		/**MOTIONLESS_MATRIX用*/
		public var defaultMatrix:Matrix3D;
		/**動かす対象*/
		public var target:Object3D;
		/**ターゲット指定などがされていて有効なアニメーションかどうか*/
		public var valid:Boolean;
		/**モーションブレンド用のブレンド直前の姿勢情報*/
		private var capturedTransform:Object;
		/**角度をブレンドする際に1度だけ近い角度に修正するフラグ*/
		private var fixRotation:Boolean;
		
		public function KeyframeAnimation(type:String = TYPE_CURVE) 
		{
			this.type = type;
			valid = false;
			blendRatio = 1;
			capturedTransform = { };
		}
		
		public function setStartTime(time:Number):void 
		{
			if (rotation) rotation.setStartTime(time);
			if (scale) scale.setStartTime(time);
			if (position) position.setStartTime(time);
			if (matrix) matrix.startTime = time;
		}
		
		public function setEndTime(time:Number):void 
		{
			if (rotation) rotation.setEndTime(time);
			if (scale) scale.setEndTime(time);
			if (position) position.setEndTime(time);
			if (matrix) matrix.endTime = time;
		}
		
		public function clone():KeyframeAnimation
		{
			var result:KeyframeAnimation = new KeyframeAnimation(type);
			result.material = material? material.clone() : null;
			result.position = position? position.clone() : null;
			result.rotation = rotation? rotation.clone() : null;
			result.scale = scale? scale.clone() : null;
			result.matrix = matrix? matrix.clone() : null;
			result.defaultMatrix = defaultMatrix? defaultMatrix.clone() : null;
			return result;
		}
		
		/**
		 * 
		 */
		public function initMaterialShader():void
		{
			uvOffsetShader = new UVOffsetShader(0, 0, 1, 1);
		}
		
		/**
		 * このアニメーションを適用するObject3Dを指定する。
		 * アニメーションの無いノードのデフォルト値はこのメソッドを呼んだ時点のObject3Dのパラメータを使う。
		 * @param	object
		 */
		public function setObject(object:Object3D):void
		{
			target = object;
			valid = (target != null);
			
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
		 * キーフレーム間の線形補完の有無を設定
		 * @param	enabled
		 */
		public function setInterpolationEnabled(enabled:Boolean):void 
		{
			if (material) material.setInterpolationEnabled(enabled);
			if (position) position.setInterpolationEnabled(enabled);
			if (rotation) rotation.setInterpolationEnabled(enabled);
			if (scale) scale.setInterpolationEnabled(enabled);
			if (matrix) matrix.interpolationEnabled = enabled;
		}
		
		/**
		 * アニメーションの時間を指定する
		 * @param	time	秒
		 */
		public function setTime(time:Number):void
		{
			if (valid == false) return;
			
			var ratio:Number = 1 - blendRatio;
			switch(type)
			{
				case TYPE_MATERIAL:
					var u:Number = (material.offsetU)? material.offsetU.getValue(time) : 0;
					var v:Number = (material.offsetV)? material.offsetV.getValue(time) : 0;
					if (blendRatio == 1)
					{
						uvOffsetShader.offsetU = u;
						uvOffsetShader.offsetV = v;
					}
					else
					{
						uvOffsetShader.offsetU = capturedTransform.offsetU * ratio + u * blendRatio;
						uvOffsetShader.offsetV = capturedTransform.offsetV * ratio + v * blendRatio;
					}
					break;
				case TYPE_CURVE:
					setCurveMatrix(time);
					break;
				case TYPE_MOTIONLESS_MATRIX:
					if (target)
					{
						if (blendRatio == 1)
						{
							target.matrix = defaultMatrix;
						}
						else
						{
							target.matrix = Matrix3D.interpolate(capturedTransform.matrix, defaultMatrix, blendRatio);
						}
					}
					break;
				case TYPE_MATRIX:
					if (target)
					{
						if (blendRatio == 1)
						{
							target.matrix = matrix.getMatrix3D(time);
						}
						else
						{
							target.matrix = Matrix3D.interpolate(capturedTransform.matrix, matrix.getMatrix3D(time), blendRatio);
						}
					}
					break;
			}
		}
		
		public function reset():void 
		{
			if (material) material.reset();
			if (position) position.reset();
			if (rotation) rotation.reset();
			if (scale) scale.reset();
			if (matrix) matrix.reset();
			setTime(0);
		}
		
		public function capture():void 
		{
			if (target == null) return;
			
			switch(type)
			{
				case TYPE_MATERIAL:
					capturedTransform.offsetU = uvOffsetShader.offsetU;
					capturedTransform.offsetV = uvOffsetShader.offsetV;
					break;
				case TYPE_CURVE:
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
					break;
				case TYPE_MATRIX:
				case TYPE_MOTIONLESS_MATRIX:
					capturedTransform.matrix = target.matrix.clone();
					break;
			}
			
			fixRotation = true;
		}
		
		public function getStartEndTime():Array 
		{
			var curves:Vector.<AnimationCurveTrack> = new Vector.<AnimationCurveTrack>;
			if (material)
			{
				if (material.offsetU) curves.push(material.offsetU);
				if (material.offsetV) curves.push(material.offsetV);
			}
			if (position)
			{
				if (position.x) curves.push(position.x);
				if (position.y) curves.push(position.y);
				if (position.z) curves.push(position.z);
			}
			if (rotation)
			{
				if (rotation.x) curves.push(rotation.x);
				if (rotation.y) curves.push(rotation.y);
				if (rotation.z) curves.push(rotation.z);
			}
			if (scale)
			{
				if (scale.x) curves.push(scale.x);
				if (scale.y) curves.push(scale.y);
				if (scale.z) curves.push(scale.z);
				
			}
			
			var start:Number = Number.MAX_VALUE;
			var end:Number = 0;
			for each (var curve:AnimationCurveTrack in curves) 
			{
				if (start > curve.startTime) start = curve.startTime;
				if (end < curve.endTime) end = curve.endTime;
			}
			if (matrix)
			{
				if (start > matrix.startTime) start = matrix.startTime;
				if (end < matrix.endTime) end = matrix.endTime;
			}
			if (start > end)
			{
				start = end;
			}
			return [start, end];
		}
		
		public function setLoop(value:Boolean):void 
		{
			if (material)
			{
				if (material.offsetU) material.offsetU.loop = value;
				if (material.offsetV) material.offsetV.loop = value;
			}
			if (position)
			{
				if (position.x) position.x.loop = value;
				if (position.y) position.y.loop = value;
				if (position.z) position.z.loop = value;
			}
			if (rotation)
			{
				if (rotation.x) rotation.x.loop = value;
				if (rotation.y) rotation.y.loop = value;
				if (rotation.z) rotation.z.loop = value;
			}
			if (scale)
			{
				if (scale.x) scale.x.loop = value;
				if (scale.y) scale.y.loop = value;
				if (scale.z) scale.z.loop = value;
				
			}
			if (matrix)
			{
				matrix.loop = value;
			}
		}
		
		private function setCurveMatrix(time:Number):void
		{
			var ratio:Number = 1 - blendRatio;
			if (position)
			{
				var pos:Vector3D = position.getVector3D(time);
				if (blendRatio == 1)
				{
					target.x = pos.x;
					target.y = pos.y;
					target.z = pos.z;
				}
				else
				{
					target.x = capturedTransform.x * ratio + pos.x * blendRatio;
					target.y = capturedTransform.y * ratio + pos.y * blendRatio;
					target.z = capturedTransform.z * ratio + pos.z * blendRatio;
				}
			}
			if (rotation)
			{
				var rot:Vector3D = rotation.getVector3D(time);
				var radian:Number = Math.PI / 180;
				if (blendRatio == 1)
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
					target.rotationX = capturedTransform.rotationX * ratio + rx * blendRatio;
					target.rotationY = capturedTransform.rotationY * ratio + ry * blendRatio;
					target.rotationZ = capturedTransform.rotationZ * ratio + rz * blendRatio;
				}
			}
			if (scale)
			{
				var scl:Vector3D = scale.getVector3D(time);
				if (blendRatio == 1)
				{
					target.scaleX = scl.x;
					target.scaleY = scl.y;
					target.scaleZ = scl.z;
				}
				else
				{
					target.scaleX = capturedTransform.scaleX * ratio + scl.x * blendRatio;
					target.scaleY = capturedTransform.scaleY * ratio + scl.y * blendRatio;
					target.scaleZ = capturedTransform.scaleZ * ratio + scl.z * blendRatio;
				}
			}
		}
		
	}

}