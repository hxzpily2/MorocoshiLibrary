package net.morocoshi.moja3d.objects 
{
	/**
	 * LODに登録したオブジェクト情報
	 * 
	 * @author tencho
	 */
	public class LODItem 
	{
		public var object:Object3D;
		public var min:Number;
		public var max:Number;
		
		public function LODItem(object:Object3D, min:Number, max:Number) 
		{
			this.object = object;
			this.min = min;
			this.max = max;
		}
		
	}

}