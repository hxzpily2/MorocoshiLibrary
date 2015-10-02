package net.morocoshi.moja3d.particle.cells 
{
	import flash.geom.Vector3D;
	import net.morocoshi.moja3d.materials.Material;
	import net.morocoshi.moja3d.objects.Object3D;
	
	/**
	 * パーティクルシステム用のSprite3D
	 * 
	 * @author tencho
	 */
	public class Particle3D extends Object3D 
	{
		/**経過時間*/
		public var time:Number = 0;
		/**寿命*/
		public var life:Number = 0;
		/**初期スケール*/
		public var initialScale:Number = 1;
		/**初期回転角*/
		public var initialRotation:Number = 0;
		/**回転速度*/
		public var spinSpeed:Number = 0;
		/**スケール加算速度*/
		public var scaleSpeed:Number = 0;
		/**加速度*/
		public var velocity:Vector3D = new Vector3D();
		
		public var materialID:int;
		
		private var _alpha:Number;
		
		/**最後にチェックしたアルファキー用インデックス*/
		public var latestIndex:int = 0;
		
		public function Particle3D(width:Number, height:Number, material:Material, alpha:Number = 1)
		{
			super();
			_alpha = alpha;
			setParticleMaterial(material);
		}
		
		public function setParticleMaterial(material:Material):void
		{
			//this.material = material;
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