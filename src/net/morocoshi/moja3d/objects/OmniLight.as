package net.morocoshi.moja3d.objects 
{
	import net.morocoshi.moja3d.bounds.BoundingBox;
	
	/**
	 * 点光源
	 * 
	 * @author tencho
	 */
	public class OmniLight extends Light3D 
	{
		private var _fadeStart:Number;
		private var _fadeEnd:Number;
		
		/**
		 * 
		 * @param	rgb	ライトの色
		 * @param	intensity	ライトの強さ
		 * @param	fadeStart	フェードアウトし始める距離
		 * @param	fadeEnd	フェードアウトし終わる距離
		 * @param	specularPower	光沢の強度
		 */
		public function OmniLight(rgb:uint, intensity:Number, fadeStart:Number, fadeEnd:Number, specularPower:Number = 1)
		{
			super(rgb, intensity, specularPower);
			_fadeStart = fadeStart;
			_fadeEnd = fadeEnd;
			boundingBox = new BoundingBox();
			updateLightBounds();
		}
		
		override public function finaly():void 
		{
			super.finaly();
			
			_fadeStart = 0;
			_fadeEnd = 0;
		}
		
		private function updateLightBounds():void 
		{
			boundingBox.setSphere(Math.max(_fadeStart, _fadeEnd));
		}
		
		override public function reference():Object3D 
		{
			var result:OmniLight = new OmniLight(getColor(), intensity, _fadeStart, _fadeEnd);
			super.referenceProperties(result);
			return result;
		}
		
		override public function clone():Object3D 
		{
			var result:OmniLight = new OmniLight(getColor(), intensity, _fadeStart, _fadeEnd);
			super.cloneProperties(result);
			return result;
		}
		
		public function get fadeStart():Number 
		{
			return _fadeStart;
		}
		
		public function set fadeStart(value:Number):void 
		{
			_fadeStart = value;
			updateLightBounds();
		}
		
		public function get fadeEnd():Number 
		{
			return _fadeEnd;
		}
		
		public function set fadeEnd(value:Number):void 
		{
			_fadeEnd = value;
			updateLightBounds();
		}
		
	}

}