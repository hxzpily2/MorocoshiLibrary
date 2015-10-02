package net.morocoshi.common.loaders.fbx.materials 
{
	/**
	 * マテリアルを割り当てるサーフェイス
	 * 
	 * @author tencho
	 */
	public class FBXSurface 
	{
		/**サーフェイスリスト内でのインデックス番号*/
		public var index:int;
		/**FBXマテリアル*/
		public var material:FBXMaterial;
		/**三角ポリ数*/
		public var numTriangle:int;
		/**このサーフェイスの開始インデックス*/
		public var indexBegin:int;
		/**ポリゴンに頂点アルファ1未満が含まれているか*/
		public var hasTransparentVertex:Boolean;
		/**マテリアルをリピート化するか*/
		public var repeatTexture:Boolean;
		
		public function FBXSurface() 
		{
		}
		
	}

}