package net.morocoshi.moja3d.loader.materials 
{
	/**
	 * マテリアルサーフェイス
	 * 
	 * @author tencho
	 */
	public class M3DSurface 
	{
		/***/
		public var indexBegin:int;
		/**△ポリゴンの数*/
		public var numTriangle:int;
		/**インデックスではなくIDなので注意*/
		public var material:int;
		/**ポリゴンに頂点アルファ1未満のものが含まれているか*/
		public var hasTransparentVertex:Boolean;
		
		public function M3DSurface() 
		{
		}
		
		public function getKey():String 
		{
			return String(hasTransparentVertex);
		}
		
	}

}