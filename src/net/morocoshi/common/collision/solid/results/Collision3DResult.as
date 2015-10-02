package net.morocoshi.common.collision.solid.results 
{
	import flash.geom.Vector3D;
	import net.morocoshi.common.collision.solid.primitives.Triangle3D;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class Collision3DResult 
	{
		/**衝突した時間（0～1）*/
		public var time:Number = 0;
		/**強制的に押し出すか*/
		public var thrust:Boolean = false;
		/***/
		public var hit:Boolean = false;
		/**衝突点*/
		public var collision:Vector3D = new Vector3D();
		/**初期状態で埋まっている場合などに押し出す座標*/
		public var thrustVector:Vector3D = new Vector3D();
		/**衝突が起こったポリゴン*/
		public var instance:Triangle3D;
		/**衝突点の法線（壁ずりに使用）*/
		public var normal:Vector3D = new Vector3D();
		/**無限平面か*/
		public var infinity:Boolean = false;
		/**ユニットが衝突点の法線方向に進んでいるか。動くコリジョンからぶつかってきた時にtrueになる可能性がある*/
		public var reverse:Boolean = false;
		/**この平面の元になるポリゴンが動いていたか*/
		public var moved:Boolean = false;
		/**衝突点までの距離（光線とポリゴンの衝突で使用）*/
		public var distance:Number = 0;
		
		public function Collision3DResult() 
		{
		}
		
		public function reset():void
		{
			time = 0;
			thrust = false;
			hit = false;
			reverse = false;
			infinity = false;
			collision.setTo(0, 0, 0);
			thrustVector.setTo(0, 0, 0);
			instance = null;
			moved = false;
		}
		
		public function clone():Collision3DResult 
		{
			var result:Collision3DResult = new Collision3DResult();
			result.infinity = infinity;
			result.hit = hit;
			result.thrust = thrust;
			result.time = time;
			result.collision.copyFrom(collision);
			result.thrustVector.copyFrom(thrustVector);
			result.normal.copyFrom(normal);
			result.instance = instance;
			result.reverse = reverse;
			return result;
		}
		
	}

}