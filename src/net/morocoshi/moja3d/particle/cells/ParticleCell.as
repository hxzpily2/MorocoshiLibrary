package net.morocoshi.moja3d.particle.cells 
{
	import flash.geom.Vector3D;
	import net.morocoshi.moja3d.materials.Material;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.objects.Object3D;
	import net.morocoshi.moja3d.particle.animators.ParticleAnimator;
	
	/**
	 * パーティクルシステム用のSprite3D
	 * 
	 * @author tencho
	 */
	public class ParticleCell extends ParticleData 
	{
		moja3d var initTime:int = 0;
		/**経過時間*/
		public var time:Number = 0;
		/**寿命*/
		public var life:Number = 0;
		/**初期スケール*/
		public var initialScale:Number = 1;
		/**初期角度*/
		public var initialRotation:Number = 0;
		/**回転速度*/
		public var spinSpeed:Number = 0;
		/**スケール加算速度*/
		public var scaleSpeed:Number = 0;
		/**加速度*/
		public var velocity:Vector3D = new Vector3D();
		
		/**最後にチェックしたアルファキー用インデックス*/
		public var latestIndex:int = 0;
		
		public var animator:ParticleAnimator;
		
		public function ParticleCell()
		{
			super();
		}
		
		public function update():void 
		{
			animator.updateParticle(this);
		}
		
		/**
		 * 時間経過率（0～1）
		 */
		public function get progress():Number
		{
			if (life <= 0 || time >= life) return 1;
			return time / life;
		}
		
	}

}