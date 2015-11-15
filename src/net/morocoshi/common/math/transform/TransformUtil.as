package net.morocoshi.common.math.transform 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import net.morocoshi.common.math.geom.Vector3DUtil;
	
	/**
	 * 姿勢制御
	 * 
	 * @author tencho
	 */
	public class TransformUtil 
	{
		static private var _fromN:Vector3D = new Vector3D;
		static private var _toN:Vector3D = new Vector3D;
		static private var _fromY:Vector3D = new Vector3D;
		static private var _fromZ:Vector3D = new Vector3D;
		static private var _toY:Vector3D = new Vector3D;
		static private var _toZ:Vector3D = new Vector3D;
		static private var localUpAxis:Vector3D = new Vector3D(0, 0, 0);
		
		/**
		 * ベクトルの向きをfromからtoへt（0～1）の割合だけ球面線形補間した新しい単位ベクトルを返す
		 * @param	from
		 * @param	to
		 * @param	t
		 * @return
		 */
		static public function slerpVector(from:Vector3D, to:Vector3D, t:Number):Vector3D
		{
			if (!from.lengthSquared || !from.lengthSquared || from.equals(to))
			{
				return from.clone();
			}
			
			_fromN.x = from.x;
			_fromN.y = from.y;
			_fromN.z = from.z;
			_toN.x = to.x;
			_toN.y = to.y;
			_toN.z = to.z;
			_fromN.normalize();
			_toN.normalize();
			
			var angle:Number = Vector3DUtil.getAngleUnit(_fromN, _toN);
			//TODO: 2つのベクトルが真逆を向いていると補間できないのでずらしてます（強引かもしれない）
			if (angle == Math.PI)
			{
				_fromN.x += 0.000001;
				if (!_fromN.y && !_fromN.z) _fromN.y += 0.000001;
				_fromN.normalize();
				angle = Vector3DUtil.getAngleUnit(_fromN, _toN);
			}
			var sin:Number = Math.sin(angle);
			if (!sin)
			{
				return _fromN.clone();
			}
			
			var sinf:Number = Math.sin(angle * (1 - t));
			var sint:Number = Math.sin(angle * t);
			var v:Vector3D = new Vector3D();
			if (sin)
			{
				v.x = (_fromN.x * sinf + _toN.x * sint) / sin;
				v.y = (_fromN.y * sinf + _toN.y * sint) / sin;
				v.z = (_fromN.z * sinf + _toN.z * sint) / sin;
			}
			v.normalize();
			
			return v;
		}
		
		/**
		 * Matrix3Dの回転成分をfromからtoへt（0～1）の割合だけ球面線形補間した新しいMatrix3Dを返す
		 * @param	from
		 * @param	to
		 * @param	t
		 * @return
		 */
		static public function slerpMatrix(from:Matrix3D, to:Matrix3D, t:Number):Matrix3D
		{
			_fromY.x = from.rawData[4];
			_fromY.y = from.rawData[5];
			_fromY.z = from.rawData[6];
			_fromZ.x = from.rawData[8];
			_fromZ.y = from.rawData[9];
			_fromZ.z = from.rawData[10];
			_toY.x = to.rawData[4];
			_toY.y = to.rawData[5];
			_toY.z = to.rawData[6];
			_toZ.x = to.rawData[8];
			_toZ.y = to.rawData[9];
			_toZ.z = to.rawData[10];
			
			var sy:Vector3D = slerpVector(_fromY, _toY, t);
			var sz:Vector3D = slerpVector(_fromZ, _toZ, t);
			var sx:Vector3D = Vector3DUtil.cross(sy, sz);
			sy = Vector3DUtil.cross(sz, sx);
			sx.normalize();
			sy.normalize();
			var m:Matrix3D = new Matrix3D();
			m.rawData = Vector.<Number>([
				sx.x, sx.y, sx.z, 0,
				sy.x, sy.y, sy.z, 0,
				sz.x, sz.y, sz.z, 0,
				0, 0, 0, 1
			]);
			return m;
		}
		
		/**
		 * 重いので使わない
		 * @param	thisMat
		 * @param	toMat
		 * @param	percent
		 * @return
		 */
		static public function interpolate(thisMat:Matrix3D, toMat:Matrix3D, percent:Number):Matrix3D
		{
			var v0:Vector3D = thisMat.decompose("quaternion")[1];
			var v1:Vector3D = toMat.decompose("quaternion")[1];
			var cosOmega:Number = v0.w * v1.w + v0.x * v1.x + v0.y * v1.y + v0.z * v1.z;
			if (cosOmega < 0)
			{
				v1.x = -v1.x;
				v1.y = -v1.y;
				v1.z = -v1.z;
				v1.w = -v1.w;
				cosOmega = -cosOmega;
			}
			
			var k0:Number;
			var k1:Number;
			if (cosOmega > 0.9999)
			{
				k0 = 1 - percent;
				k1 = percent;
			}
			else
			{
				var sinOmega:Number = Math.sqrt(1 - cosOmega*cosOmega);
				var omega:Number = Math.atan2(sinOmega,cosOmega);
				var oneOverSinOmega:Number = 1/sinOmega;
				k0 = Math.sin((1-percent)*omega)*oneOverSinOmega;
				k1 = Math.sin(percent*omega)*oneOverSinOmega;
			}
			
			var scale_x:Number = thisMat.decompose("quaternion")[2].x * (1 - percent) + toMat.decompose("quaternion")[2].x * percent;
			var scale_y:Number = thisMat.decompose("quaternion")[2].y * (1 - percent) + toMat.decompose("quaternion")[2].y * percent;
			var scale_z:Number = thisMat.decompose("quaternion")[2].z * (1 - percent) + toMat.decompose("quaternion")[2].z * percent;
			var tx:Number = thisMat.decompose("quaternion")[0].x * (1 - percent) + toMat.decompose("quaternion")[0].x * percent;
			var ty:Number = thisMat.decompose("quaternion")[0].y * (1 - percent) + toMat.decompose("quaternion")[0].y * percent;
			var tz:Number = thisMat.decompose("quaternion")[0].z * (1 - percent) + toMat.decompose("quaternion")[0].z * percent;
			var x:Number = v0.x * k0 + v1.x * k1;
			var y:Number = v0.y * k0 + v1.y * k1;
			var z:Number = v0.z * k0 + v1.z * k1;
			var w:Number = v0.w * k0 + v1.w * k1;
			var _q:Vector.<Number> = new Vector.<Number>(16, true);
			_q[0] = (1 - 2 * y * y - 2 * z * z) * scale_x;
			_q[1] = (2 * x * y + 2 * w * z) * scale_x;
			_q[2] = (2 * x * z - 2 * w * y) * scale_x;
			_q[3] = 0;
			_q[4] = 2 * x * y - 2 * w * z * scale_y;
			_q[5] = (1 - 2 * x * x - 2 * z * z) * scale_y;
			_q[6] = 2 * y * z + 2 * w * x * scale_y;
			_q[7] = 0;
			_q[8] = 2 * x * z + 2 * w * y * scale_z;
			_q[9] = 2 * y * z - 2 * w * x * scale_z;
			_q[10] = (1 - 2 * x * x - 2 * y * y) * scale_z;
			_q[11] = 0;
			_q[12] = tx;
			_q[13] = ty;
			_q[14] = tz;
			_q[15] = 1;
			
			//var v:Vector3D = new Vector3D(v0.x * k0 + v1.x * k1, v0.y * k0 + v1.y * k1, v0.z * k0 + v1.z * k1, v0.w * k0 + v1.w * k1);
			
			return new Matrix3D(_q);
		}
		
		static private var rawData:Vector.<Number>;
		static public function transformVector(vector:Vector3D, matrix:Matrix3D):void
		{
			rawData = matrix.rawData;
			var vx:Number = rawData[0] * vector.x + rawData[4] * vector.y + rawData[8]  * vector.z + rawData[12];
			var vy:Number = rawData[1] * vector.x + rawData[5] * vector.y + rawData[9]  * vector.z + rawData[13];
			var vz:Number = rawData[2] * vector.x + rawData[6] * vector.y + rawData[10] * vector.z + rawData[14];
			vector.x = vx;
			vector.y = vy;
			vector.z = vz;
		}
		
		static public function deltaTransformVector(vector:Vector3D, matrix:Matrix3D):void
		{
			rawData = matrix.rawData;
			var vx:Number = rawData[0] * vector.x + rawData[4] * vector.y + rawData[8]  * vector.z;
			var vy:Number = rawData[1] * vector.x + rawData[5] * vector.y + rawData[9]  * vector.z;
			var vz:Number = rawData[2] * vector.x + rawData[6] * vector.y + rawData[10] * vector.z;
			vector.x = vx;
			vector.y = vy;
			vector.z = vz;
		}
		
		static private var front:Vector3D = new Vector3D();
		static private var right:Vector3D = new Vector3D();
		static private var up:Vector3D = new Vector3D();
		static private var xAxis:Vector3D = new Vector3D();
		static private var yAxis:Vector3D = new Vector3D();
		static private var zAxis:Vector3D = new Vector3D();
		static private var scale:Vector3D = new Vector3D();
		
		static public function lookAt3D(matrix:Matrix3D, point:Vector3D, frontAxis:String, topAxis:String, upAxis:Vector3D = null, applyScale:Boolean = true):void
		{
			lookAtXYZ(matrix, point.x, point.y, point.z, frontAxis, topAxis, upAxis, applyScale);
		}
		
		static public function lookAtPivot3D(matrix:Matrix3D, point:Vector3D, frontAxis:String, pivotAxis:String, applyScale:Boolean = true):void
		{
			lookAtPivotXYZ(matrix, point.x, point.y, point.z, frontAxis, pivotAxis, applyScale);
		}
		
		/**
		 * 
		 * @param	matrix
		 * @param	x
		 * @param	y
		 * @param	z
		 * @param	frontAxis
		 * @param	pivotAxis
		 * @param	applyScale
		 */
		static public function lookAtPivotXYZ(matrix:Matrix3D, x:Number, y:Number, z:Number, frontAxis:String, pivotAxis:String, applyScale:Boolean = true):void
		{
			rawData = matrix.rawData;
			
			switch(pivotAxis)
			{
				case "+x": case "-x": case "x":
					up.setTo(rawData[0], rawData[1], rawData[2]);
					break;
				case "+y": case "-y": case "y":
					up.setTo(rawData[4], rawData[5], rawData[6]);
					break;
				case "+z": case "-z": case "z":
					up.setTo(rawData[8], rawData[9], rawData[10]);
					break;
			}
			
			front.x = x - rawData[12];
			front.y = y - rawData[13];
			front.z = z - rawData[14];
			//視点と注視点が同じだったら計算ができない
			if (front.x == 0 && front.y == 0 && front.z == 0)
			{
				return;
			}
			
			//TODO: 内積計算でエラーが出る可能性がある？
			right.x = (front.y * up.z) - (front.z * up.y);
			right.y = (front.z * up.x) - (front.x * up.z);
			right.z = (front.x * up.y) - (front.y * up.x);
			front.x = (up.y * right.z) - (up.z * right.y);
			front.y = (up.z * right.x) - (up.x * right.z);
			front.z = (up.x * right.y) - (up.y * right.x);
			front.normalize();
			right.normalize();
			up.normalize();
			
			if (applyScale)
			{
				scale.setTo(rawData[0], rawData[1], rawData[2]);
				xAxis.scaleBy(scale.length);
				scale.setTo(rawData[4], rawData[5], rawData[6]);
				yAxis.scaleBy(scale.length);
				scale.setTo(rawData[8], rawData[9], rawData[10]);
				zAxis.scaleBy(scale.length);
			}
			
			switch(pivotAxis)
			{
				case "+y": case "-y": case "y":
					switch(frontAxis)
					{
						case "+x":
							setAxisF(xAxis, front);
							setAxisF(yAxis, up);
							setAxisF(zAxis, right);
							break;
						case "-x":
							setAxisR(xAxis, front);
							setAxisF(yAxis, up);
							setAxisR(zAxis, right);
							break;
						case "+z":
							setAxisR(xAxis, right);
							setAxisF(yAxis, up);
							setAxisF(zAxis, front);
							break;
						case "-z":
							setAxisF(xAxis, right);
							setAxisF(yAxis, up);
							setAxisR(zAxis, front);
							break;
						default:
							errorLookAt();
					}
					break;
				case "+x": case "-x": case "x":
					switch(frontAxis)
					{
						case "+y":
							setAxisF(xAxis, up);
							setAxisF(yAxis, front);
							setAxisR(zAxis, right);
							break;
						case "-y":
							setAxisF(xAxis, up);
							setAxisR(yAxis, front);
							setAxisF(zAxis, right);
							break;
						case "+z":
							setAxisF(xAxis, up);
							setAxisF(yAxis, right);
							setAxisF(zAxis, front);
							break;
						case "-z":
							setAxisF(xAxis, up);
							setAxisR(yAxis, right);
							setAxisR(zAxis, front);
							break;
						default:
							errorLookAt();
					}
					break;
				case "+z": case "-z": case "z":
					switch(frontAxis)
					{
						case "+y":
							setAxisF(xAxis, right);
							setAxisF(yAxis, front);
							setAxisF(zAxis, up);
							break;
						case "-y":
							setAxisR(xAxis, right);
							setAxisR(yAxis, front);
							setAxisF(zAxis, up);
							break;
						case "+x":
							setAxisF(xAxis, front);
							setAxisR(yAxis, right);
							setAxisF(zAxis, up);
							break;
						case "-x":
							setAxisR(xAxis, front);
							setAxisF(yAxis, right);
							setAxisF(zAxis, up);
							break;
						default:
							errorLookAt();
					}
					break;
				default:
					errorLookAt();
			}
			
			rawData[0] = xAxis.x;
			rawData[1] = xAxis.y;
			rawData[2] = xAxis.z;
			rawData[3] = 0;
			rawData[4] = yAxis.x;
			rawData[5] = yAxis.y;
			rawData[6] = yAxis.z;
			rawData[7] = 0;
			rawData[8] = zAxis.x;
			rawData[9] = zAxis.y;
			rawData[10] = zAxis.z;
			rawData[11] = 0;
			rawData[15] = 1;
			
			matrix.copyRawDataFrom(rawData);
			/*
			= new <Number>[
				xAxis.x, xAxis.y, xAxis.z, 0,
				yAxis.x, yAxis.y, yAxis.z, 0,
				zAxis.x, zAxis.y, zAxis.z, 0,
				rawData[12], rawData[13], rawData[14], 1
			];*/
		}
		
		static public function lookAtXYZ(matrix:Matrix3D, x:Number, y:Number, z:Number, frontAxis:String, topAxis:String, upAxis:Vector3D = null, applyScale:Boolean = true):void
		{
			if (upAxis == null)
			{
				localUpAxis.x = 0;
				localUpAxis.y = 0;
				localUpAxis.z = 1;
			}
			else
			{
				localUpAxis.x = upAxis.x;
				localUpAxis.y = upAxis.y;
				localUpAxis.z = upAxis.z;
			}
			
			rawData = matrix.rawData;
			
			front.x = x - rawData[12];
			front.y = y - rawData[13];
			front.z = z - rawData[14];
			//視点と注視点が同じだったら計算ができない
			if (front.x == 0 && front.y == 0 && front.z == 0)
			{
				return;
			}
			right.x = (front.y * localUpAxis.z) - (front.z * localUpAxis.y);
			right.y = (front.z * localUpAxis.x) - (front.x * localUpAxis.z);
			right.z = (front.x * localUpAxis.y) - (front.y * localUpAxis.x);
			if (right.x == 0 && right.y == 0 && right.z == 0)
			{
				front.normalize();
				if (front.x == 1 && front.y == 0 && front.z == 0)
				{
					localUpAxis.x = 0;
					localUpAxis.y = 1;
					localUpAxis.z = 0;
				}
				else
				{
					localUpAxis.x = 1;
					localUpAxis.y = 0;
					localUpAxis.z = 0;
				}
				right.x = (front.y * localUpAxis.z) - (front.z * localUpAxis.y);
				right.y = (front.z * localUpAxis.x) - (front.x * localUpAxis.z);
				right.z = (front.x * localUpAxis.y) - (front.y * localUpAxis.x);
			}
			up.x = (right.y * front.z) - (right.z * front.y);
			up.y = (right.z * front.x) - (right.x * front.z);
			up.z = (right.x * front.y) - (right.y * front.x);
			front.normalize();
			right.normalize();
			up.normalize();
			
			switch(frontAxis)
			{
				case "+y":
					switch(topAxis)
					{
						case "+z":
							setAxisF(xAxis, right);
							setAxisF(yAxis, front);
							setAxisF(zAxis, up);
							break;
						case "-z":
							setAxisR(xAxis, right);
							setAxisF(yAxis, front);
							setAxisR(zAxis, up);
							break;
						case "+x":
							setAxisF(xAxis, up);
							setAxisF(yAxis, front);
							setAxisR(zAxis, right);
							break;
						case "-x":
							setAxisR(xAxis, up);
							setAxisF(yAxis, front);
							setAxisF(zAxis, right);
							break;
						default:
							errorLookAt();
					}
					break;
				case "-y":
					switch(topAxis)
					{
						case "+z":
							setAxisR(xAxis, right);
							setAxisR(yAxis, front);
							setAxisF(zAxis, up);
							break;
						case "-z":
							setAxisF(xAxis, right);
							setAxisR(yAxis, front);
							setAxisR(zAxis, up);
							break;
						case "+x":
							setAxisF(xAxis, up);
							setAxisR(yAxis, front);
							setAxisF(zAxis, right);
							break;
						case "-x":
							setAxisR(xAxis, up);
							setAxisR(yAxis, front);
							setAxisR(zAxis, right);
							break;
						default:
							errorLookAt();
					}
					break;
				case "-z":
					switch(topAxis)
					{
						case "+y":
							setAxisF(xAxis, right);
							setAxisF(yAxis, up);
							setAxisR(zAxis, front);
							break;
						case "-y":
							setAxisR(xAxis, right);
							setAxisR(yAxis, up);
							setAxisR(zAxis, front);
							break;
						case "+x":
							setAxisF(xAxis, up);
							setAxisR(yAxis, right);
							setAxisR(zAxis, front);
							break;
						case "-x":
							setAxisR(xAxis, up);
							setAxisF(yAxis, right);
							setAxisR(zAxis, front);
							break;
						default:
							errorLookAt();
					}
					break;
				case "+z":
					switch(topAxis)
					{
						case "+y":
							setAxisR(xAxis, right);
							setAxisF(yAxis, up);
							setAxisF(zAxis, front);
							break;
						case "-y":
							setAxisF(xAxis, right);
							setAxisR(yAxis, up);
							setAxisF(zAxis, front);
							break;
						case "+x":
							setAxisF(xAxis, up);
							setAxisF(yAxis, right);
							setAxisF(zAxis, front);
							break;
						case "-x":
							setAxisR(xAxis, up);
							setAxisR(yAxis, right);
							setAxisF(zAxis, front);
							break;
						default:
							errorLookAt();
					}
					break;
				case "+x":
					switch(topAxis)
					{
						case "+z":
							setAxisF(xAxis, front);
							setAxisR(yAxis, right);
							setAxisF(zAxis, up);
							break;
						case "-z":
							setAxisF(xAxis, front);
							setAxisF(yAxis, right);
							setAxisR(zAxis, up);
							break;
						case "+y":
							setAxisF(xAxis, front);
							setAxisF(yAxis, up);
							setAxisF(zAxis, right);
							break;
						case "-y":
							setAxisF(xAxis, front);
							setAxisR(yAxis, up);
							setAxisR(zAxis, right);
							break;
						default:
							errorLookAt();
					}
					break;
				case "-x":
					switch(topAxis)
					{
						case "+z":
							setAxisR(xAxis, front);
							setAxisF(yAxis, right);
							setAxisF(zAxis, up);
							break;
						case "-z":
							setAxisR(xAxis, front);
							setAxisR(yAxis, right);
							setAxisR(zAxis, up);
							break;
						case "+y":
							setAxisR(xAxis, front);
							setAxisF(yAxis, up);
							setAxisR(zAxis, right);
							break;
						case "-y":
							setAxisR(xAxis, front);
							setAxisR(yAxis, up);
							setAxisF(zAxis, right);
							break;
						default:
							errorLookAt();
					}
					break;
				default:
					errorLookAt();
			}
			
			if (applyScale)
			{
				scale.setTo(rawData[0], rawData[1], rawData[2]);
				xAxis.scaleBy(scale.length);
				scale.setTo(rawData[4], rawData[5], rawData[6]);
				yAxis.scaleBy(scale.length);
				scale.setTo(rawData[8], rawData[9], rawData[10]);
				zAxis.scaleBy(scale.length);
			}
			
			rawData[0] = xAxis.x;
			rawData[1] = xAxis.y;
			rawData[2] = xAxis.z;
			rawData[3] = 0;
			rawData[4] = yAxis.x;
			rawData[5] = yAxis.y;
			rawData[6] = yAxis.z;
			rawData[7] = 0;
			rawData[8] = zAxis.x;
			rawData[9] = zAxis.y;
			rawData[10] = zAxis.z;
			rawData[11] = 0;
			rawData[15] = 1;
			
			matrix.copyRawDataFrom(rawData);
			/*= new <Number>[
				xAxis.x, xAxis.y, xAxis.z, 0,
				yAxis.x, yAxis.y, yAxis.z, 0,
				zAxis.x, zAxis.y, zAxis.z, 0,
				rawData[12], rawData[13], rawData[14], 1
			];*/
		}
		
		static private function setAxisF(axis:Vector3D, from:Vector3D):void 
		{
			axis.x = from.x;
			axis.y = from.y;
			axis.z = from.z;
		}
		
		static private function setAxisR(axis:Vector3D, from:Vector3D):void 
		{
			axis.x = -from.x;
			axis.y = -from.y;
			axis.z = -from.z;
		}
		
		static private function errorLookAt():void 
		{
			throw new Error("lookAt()で無効な軸パラメータが指定されています。");
		}
		
		/*
		static public function lookAtZPYP(matrix:Matrix3D, x:Number, y:Number, z:Number, upAxis:Vector3D = null, applyScale:Boolean = true):void
		{
			if (upAxis == null) upAxis = Vector3D.Z_AXIS;
			
			var rawData:Vector.<Number> = matrix.rawData;
			front.x = x - rawData[12];
			front.y = y - rawData[13];
			front.z = z - rawData[14];
			
			right.x = (front.y * upAxis.z) - (front.z * upAxis.y);
			right.y = (front.z * upAxis.x) - (front.x * upAxis.z);
			right.z = (front.x * upAxis.y) - (front.y * upAxis.x);
			
			up.x = (right.y * front.z) - (right.z * front.y);
			up.y = (right.z * front.x) - (right.x * front.z);
			up.z = (right.x * front.y) - (right.y * front.x);
			
			front.normalize();
			right.normalize();
			up.normalize();
			
			if (applyScale)
			{
				scale.setTo(rawData[0], rawData[1], rawData[2]);
				right.scaleBy(scale.length);
				scale.setTo(rawData[4], rawData[5], rawData[6]);
				up.scaleBy(scale.length);
				scale.setTo(rawData[8], rawData[9], rawData[10]);
				front.scaleBy(scale.length);
			}
			
			matrix.rawData = new <Number>[
				-right.x, -right.y, -right.z, 0,
				up.x, up.y, up.z, 0,
				front.x, front.y, front.z, 0,
				rawData[12], rawData[13], rawData[14], 1
			];
		}
		
		static public function lookAtZNYP(matrix:Matrix3D, x:Number, y:Number, z:Number, upAxis:Vector3D = null):void
		{
			if (upAxis == null) upAxis = Vector3D.Z_AXIS;
			
			var rawData:Vector.<Number> = matrix.rawData;
			front.x = x - rawData[12];
			front.y = y - rawData[13];
			front.z = z - rawData[14];
			
			right.x = (front.y * upAxis.z) - (front.z * upAxis.y);
			right.y = (front.z * upAxis.x) - (front.x * upAxis.z);
			right.z = (front.x * upAxis.y) - (front.y * upAxis.x);
			
			up.x = (right.y * front.z) - (right.z * front.y);
			up.y = (right.z * front.x) - (right.x * front.z);
			up.z = (right.x * front.y) - (right.y * front.x);
			
			front.normalize();
			right.normalize();
			up.normalize();
			
			matrix.rawData = new <Number>[
				right.x, right.y, right.z, 0,
				up.x, up.y, up.z, 0,
				-front.x, -front.y, -front.z, 0,
				rawData[12], rawData[13], rawData[14], 1
			];
		}
		
		static public function lookAtYPZP(matrix:Matrix3D, x:Number, y:Number, z:Number, upAxis:Vector3D = null):void
		{
			if (upAxis == null) upAxis = Vector3D.Z_AXIS;
			
			var rawData:Vector.<Number> = matrix.rawData;
			front.x = x - rawData[12];
			front.y = y - rawData[13];
			front.z = z - rawData[14];
			
			right.x = (front.y * upAxis.z) - (front.z * upAxis.y);
			right.y = (front.z * upAxis.x) - (front.x * upAxis.z);
			right.z = (front.x * upAxis.y) - (front.y * upAxis.x);
			
			up.x = (right.y * front.z) - (right.z * front.y);
			up.y = (right.z * front.x) - (right.x * front.z);
			up.z = (right.x * front.y) - (right.y * front.x);
			
			front.normalize();
			right.normalize();
			up.normalize();
			
			matrix.rawData = new <Number>[
				right.x, right.y, right.z, 0,
				front.x, front.y, front.z, 0,
				up.x, up.y, up.z, 0,
				rawData[12], rawData[13], rawData[14], 1
			];
		}
		
		static public function lookAtYNZP(matrix:Matrix3D, x:Number, y:Number, z:Number, upAxis:Vector3D = null, applyScale:Boolean = true):void
		{
			if (upAxis == null) upAxis = Vector3D.Z_AXIS;
			
			var rawData:Vector.<Number> = matrix.rawData;
			front.x = x - rawData[12];
			front.y = y - rawData[13];
			front.z = z - rawData[14];
			
			right.x = (front.y * upAxis.z) - (front.z * upAxis.y);
			right.y = (front.z * upAxis.x) - (front.x * upAxis.z);
			right.z = (front.x * upAxis.y) - (front.y * upAxis.x);
			
			up.x = (right.y * front.z) - (right.z * front.y);
			up.y = (right.z * front.x) - (right.x * front.z);
			up.z = (right.x * front.y) - (right.y * front.x);
			
			front.normalize();
			right.normalize();
			up.normalize();
			
			if (applyScale)
			{
				scale.setTo(rawData[0], rawData[1], rawData[2]);
				right.scaleBy(scale.length);
				scale.setTo(rawData[4], rawData[5], rawData[6]);
				front.scaleBy(scale.length);
				scale.setTo(rawData[8], rawData[9], rawData[10]);
				up.scaleBy(scale.length);
			}
			
			matrix.rawData = new <Number>[
				-right.x, -right.y, -right.z, 0,
				-front.x, -front.y, -front.z, 0,
				up.x, up.y, up.z, 0,
				rawData[12], rawData[13], rawData[14], 1
			];
		}
		
		static public function lookAtXPZP(matrix:Matrix3D, x:Number, y:Number, z:Number, upAxis:Vector3D = null):void
		{
			if (upAxis == null) upAxis = Vector3D.Z_AXIS;
			
			var rawData:Vector.<Number> = matrix.rawData;
			front.x = x - rawData[12];
			front.y = y - rawData[13];
			front.z = z - rawData[14];
			
			right.x = (front.y * upAxis.z) - (front.z * upAxis.y);
			right.y = (front.z * upAxis.x) - (front.x * upAxis.z);
			right.z = (front.x * upAxis.y) - (front.y * upAxis.x);
			
			up.x = (right.y * front.z) - (right.z * front.y);
			up.y = (right.z * front.x) - (right.x * front.z);
			up.z = (right.x * front.y) - (right.y * front.x);
			
			front.normalize();
			right.normalize();
			up.normalize();
			
			matrix.rawData = new <Number>[
				front.x, front.y, front.z, 0,
				-right.x, -right.y, -right.z, 0,
				up.x, up.y, up.z, 0,
				rawData[12], rawData[13], rawData[14], 1
			];
		}
		
			static public function lookAtXNZP(matrix:Matrix3D, x:Number, y:Number, z:Number, upAxis:Vector3D = null):void
		{
			if (upAxis == null) upAxis = Vector3D.Z_AXIS;
			
			var rawData:Vector.<Number> = matrix.rawData;
			front.x = x - rawData[12];
			front.y = y - rawData[13];
			front.z = z - rawData[14];
			
			right.x = (front.y * upAxis.z) - (front.z * upAxis.y);
			right.y = (front.z * upAxis.x) - (front.x * upAxis.z);
			right.z = (front.x * upAxis.y) - (front.y * upAxis.x);
			
			up.x = (right.y * front.z) - (right.z * front.y);
			up.y = (right.z * front.x) - (right.x * front.z);
			up.z = (right.x * front.y) - (right.y * front.x);
			
			front.normalize();
			right.normalize();
			up.normalize();
			
			matrix.rawData = new <Number>[
				-front.x, -front.y, -front.z, 0,
				right.x, right.y, right.z, 0,
				up.x, up.y, up.z, 0,
				rawData[12], rawData[13], rawData[14], 1
			];
		}
		*/
		
	}

}