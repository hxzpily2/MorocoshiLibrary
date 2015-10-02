package net.morocoshi.moja3d.loader.objects 
{
	/**
	 * ...
	 * @author tencho
	 */
	public class M3DBone extends M3DObject 
	{
		/**何番目のボーンか。Stage3Dでの配列処理で使う*/
		public var index:int;
		/**どの頂点にも関連付けられていなかったらfalse*/
		public var enabled:Boolean;
		/**Matrix3D*/
		public var transformLink:Vector.<Number>;
		
		public function M3DBone() 
		{
		}
		
	}

}