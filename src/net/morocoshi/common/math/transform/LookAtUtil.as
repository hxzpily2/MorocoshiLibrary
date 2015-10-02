package net.morocoshi.common.math.transform 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import net.morocoshi.moja3d.objects.Object3D;
	
	/**
	 * LookAt処理
	 * 
	 * @author tencho
	 */
	public class LookAtUtil
	{
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		/**
		 * lookAt用Matrix3Dからyawを計算する（ローカルX軸プラス方向が正面）
		 * @param	matrix
		 * @return
		 */
		static public function getYaw(matrix:Matrix3D):Number
		{
			var data:Vector.<Number> = matrix.rawData;
			var x:Number = data[0];
			var y:Number = data[1];
			return Math.atan2(y, x);
		}
		
		/**
		 * lookAt用Matrix3Dからpitchを計算する（ローカルX軸プラス方向が正面）
		 * @param	matrix
		 * @return
		 */
		static public function getPitch(matrix:Matrix3D):Number
		{
			var data:Vector.<Number> = matrix.rawData;
			var x:Number = data[0];
			var y:Number = data[1];
			var z:Number = data[2];
			var xy:Number = Math.sqrt(x * x + y * y);
			return Math.atan2(z, xy);
		}
		
		/**
		 * Alternativa3DカメラのMatrix3Dからyawを計算する
		 * @param	matrix
		 * @return
		 */
		static public function getCameraYaw(matrix:Matrix3D):Number
		{
			var data:Vector.<Number> = matrix.rawData;
			var x:Number = data[8];
			var y:Number = data[9];
			return Math.atan2(y, x);
		}
		
		/**
		 * Alternativa3DカメラのMatrix3Dからpitchを計算する
		 * @param	matrix
		 * @return
		 */
		static public function getCameraPitch(matrix:Matrix3D):Number
		{
			var data:Vector.<Number> = matrix.rawData;
			var x:Number = data[8];
			var y:Number = data[9];
			var z:Number = data[10];
			var xy:Number = Math.sqrt(x * x + y * y);
			return Math.atan2(z, xy);
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		/**
		 * lookAt用Matrix3D(Yプラス正面)をカメラ用に変換する
		 * @param	matrix
		 * @return
		 */
		static public function toCameraMatrix(matrix:Matrix3D):Matrix3D
		{
			var data:Vector.<Vector3D> = matrix.decompose();
			data[1].x += Math.PI * -0.5;
			var mtx:Matrix3D = new Matrix3D();
			mtx.recompose(data);
			return mtx;
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		/**
		 * カメラを指定の座標に向かせるMatrix3Dを計算する
		 * @param	position
		 * @param	target
		 * @param	upAxis
		 * @return
		 */
		static public function cameraLookAt(position:Vector3D, target:Vector3D, upAxis:Vector3D = null):Matrix3D
		{
			if (!upAxis) upAxis = Vector3D.Z_AXIS;
			var yAxis:Vector3D = target.subtract(position);
			var xAxis:Vector3D = yAxis.crossProduct(upAxis);
			var zAxis:Vector3D = xAxis.crossProduct(yAxis);
			xAxis.normalize();
			yAxis.normalize();
			zAxis.normalize();
			var rawData:Vector.<Number> = Vector.<Number>([
				xAxis.x, xAxis.y, xAxis.z, 0,
				yAxis.x, yAxis.y, yAxis.z, 0,
				zAxis.x, zAxis.y, zAxis.z, 0,
				position.x, position.y, position.z, 1
			]);
			var matrix:Matrix3D = new Matrix3D(rawData);
			var data:Vector.<Vector3D> = matrix.decompose();
			data[1].x += Math.PI * -0.5;
			matrix.recompose(data);
			return matrix;
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		/**
		 * positionの位置からtargetの位置を見た時のMatrix3Dを計算する（ローカルX軸プラス方向が正面）
		 * @param	position
		 * @param	target
		 * @param	up
		 * @return
		 */
		static public function lookAt(position:Vector3D, target:Vector3D, upAxis:Vector3D = null):Matrix3D
		{
			if (!upAxis) upAxis = Vector3D.Z_AXIS;
			var xAxis:Vector3D = target.subtract(position);
			var yAxis:Vector3D = upAxis.crossProduct(xAxis);
			var zAxis:Vector3D = xAxis.crossProduct(yAxis);
			xAxis.normalize();
			yAxis.normalize();
			zAxis.normalize();
			var rawData:Vector.<Number> = Vector.<Number>([
				xAxis.x, xAxis.y, xAxis.z, 0,
				yAxis.x, yAxis.y, yAxis.z, 0,
				zAxis.x, zAxis.y, zAxis.z, 0,
				position.x, position.y, position.z, 1
			]);
			
			return new Matrix3D(rawData);
		}
		
		/**
		 * positionの位置からtargetの位置を見た時のMatrix3Dを計算する（ローカルY軸プラス方向が正面）
		 * @param	position
		 * @param	target
		 * @param	upAxis
		 * @return
		 */
		static public function lookAtY(position:Vector3D, target:Vector3D, upAxis:Vector3D = null):Matrix3D
		{
			if (!upAxis) upAxis = Vector3D.Z_AXIS;
			var yAxis:Vector3D = target.subtract(position);
			var xAxis:Vector3D = yAxis.crossProduct(upAxis);
			var zAxis:Vector3D = xAxis.crossProduct(yAxis);
			xAxis.normalize();
			yAxis.normalize();
			zAxis.normalize();
			var rawData:Vector.<Number> = Vector.<Number>([
				xAxis.x, xAxis.y, xAxis.z, 0,
				yAxis.x, yAxis.y, yAxis.z, 0,
				zAxis.x, zAxis.y, zAxis.z, 0,
				position.x, position.y, position.z, 1
			]);
			
			return new Matrix3D(rawData);
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Object3Dが指定座標を向いた時のMatrix3Dを計算する（ローカルX軸プラス方向が正面）
		 * @param	position
		 * @param	target
		 * @param	upAxis
		 * @return
		 */
		static private function objectLookAtX(object:Object3D, target:Vector3D, upAxis:Vector3D = null):Matrix3D
		{
			if (!upAxis) upAxis = Vector3D.Z_AXIS;
			var position:Vector3D = object.matrix.position;
			
			var xAxis:Vector3D = target.subtract(position);
			var yAxis:Vector3D = upAxis.crossProduct(xAxis);
			var zAxis:Vector3D = xAxis.crossProduct(yAxis);
			xAxis.normalize();
			yAxis.normalize();
			zAxis.normalize();
			xAxis.scaleBy(object.scaleX);
			yAxis.scaleBy(object.scaleY);
			zAxis.scaleBy(object.scaleZ);
			var rawData:Vector.<Number> = Vector.<Number>([
				xAxis.x, xAxis.y, xAxis.z, 0,
				yAxis.x, yAxis.y, yAxis.z, 0,
				zAxis.x, zAxis.y, zAxis.z, 0,
				position.x, position.y, position.z, 1
			]);
			
			var matrix:Matrix3D = new Matrix3D(rawData);
			
			return matrix;
		}
		
		/**
		 * Object3Dが指定座標を向いた時のMatrix3Dを計算する（ローカルY軸プラス方向が正面）
		 * @param	object
		 * @param	target
		 * @param	upAxis
		 * @return
		 */
		static private function objectLookAtY(object:Object3D, target:Vector3D, upAxis:Vector3D = null):Matrix3D
		{
			if (!upAxis) upAxis = Vector3D.Z_AXIS;
			var position:Vector3D = object.matrix.position;
			
			var yAxis:Vector3D = target.subtract(position);
			var xAxis:Vector3D = yAxis.crossProduct(upAxis);
			var zAxis:Vector3D = xAxis.crossProduct(yAxis);
			xAxis.normalize();
			yAxis.normalize();
			zAxis.normalize();
			xAxis.scaleBy(object.scaleX);
			yAxis.scaleBy(object.scaleY);
			zAxis.scaleBy(object.scaleZ);
			var rawData:Vector.<Number> = Vector.<Number>([
				xAxis.x, xAxis.y, xAxis.z, 0,
				yAxis.x, yAxis.y, yAxis.z, 0,
				zAxis.x, zAxis.y, zAxis.z, 0,
				position.x, position.y, position.z, 1
			]);
			
			var matrix:Matrix3D = new Matrix3D(rawData);
			
			return matrix;
		}
		
		/**
		 * Object3Dが指定座標を向いた時のMatrix3Dを計算する（正面Z軸プラス 上面Y軸プラス）
		 * @param	object
		 * @param	target
		 * @param	upAxis
		 * @return
		 */
		static public function objectLookAtZY(object:Object3D, target:Vector3D, upAxis:Vector3D = null):Matrix3D
		{
			if (!upAxis) upAxis = Vector3D.Z_AXIS;
			var position:Vector3D = object.matrix.position;
			
			var zAxis:Vector3D = target.subtract(position);
			var xAxis:Vector3D = upAxis.crossProduct(zAxis);
			var yAxis:Vector3D = zAxis.crossProduct(xAxis);
			xAxis.normalize();
			yAxis.normalize();
			zAxis.normalize();
			xAxis.scaleBy(object.scaleX);
			yAxis.scaleBy(object.scaleY);
			zAxis.scaleBy(object.scaleZ);
			var rawData:Vector.<Number> = Vector.<Number>([
				xAxis.x, xAxis.y, xAxis.z, 0,
				yAxis.x, yAxis.y, yAxis.z, 0,
				zAxis.x, zAxis.y, zAxis.z, 0,
				position.x, position.y, position.z, 1
			]);
			
			var matrix:Matrix3D = new Matrix3D(rawData);
			
			return matrix;
		}
		
	}

}