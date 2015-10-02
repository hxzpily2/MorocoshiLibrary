package net.morocoshi.moja3d.objects 
{
	import net.morocoshi.moja3d.bounds.BoundingBox;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class OmniLight extends Light3D 
	{
		private var _fadeStart:Number;
		private var _fadeEnd:Number;
		
		public function OmniLight(rgb:uint, intensity:Number, fadeStart:Number, fadeEnd:Number, specularPower:Number = 1)
		{
			super(rgb, intensity, specularPower);
			_fadeStart = fadeStart;
			_fadeEnd = fadeEnd;
			boundingBox = new BoundingBox();
			updateBounds();
		}
		
		private function updateBounds():void 
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
			updateBounds();
		}
		
		public function get fadeEnd():Number 
		{
			return _fadeEnd;
		}
		
		public function set fadeEnd(value:Number):void 
		{
			_fadeEnd = value;
			updateBounds();
		}
		
	}

}