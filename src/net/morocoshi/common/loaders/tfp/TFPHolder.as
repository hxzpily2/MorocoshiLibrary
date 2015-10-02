package net.morocoshi.common.loaders.tfp 
{
	import flash.display.BitmapData;
	import flash.media.Sound;
	import flash.utils.ByteArray;
	
	/**
	 * 各種アセットデータの入れ物
	 * 
	 * @author tencho
	 */
	public class TFPHolder 
	{
		/**このTFPHolderが持つ全アセットデータ。keyはファイルパス。*/
		public var asset:Object;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function TFPHolder() 
		{
			asset = { };
		}
		
		//--------------------------------------------------------------------------
		//
		//  キャッシュ管理
		//
		//--------------------------------------------------------------------------
		
		/**
		 * このTFPHolder内の素材の参照を削除し、TFPLoaderのキャッシュからこのTFPHolderの素材のみ削除します。
		 */
		public function clearCache():void 
		{
			for (var key:String in asset) 
			{
				delete TFPLoader.assetCache[key];
			}
			asset = { };
		}
		
		//--------------------------------------------------------------------------
		//
		//  アセットデータの取得
		//
		//--------------------------------------------------------------------------
		
		/**
		 * ファイルパスでアセットを取得する。
		 * @param	path
		 * @return
		 */
		public function getAsset(path:String):* 
		{
			if (!path)
			{
				throw new Error("[TFPHolder]アセット取得用のパスが空文字かnullになっています。");
			}
			
			if (asset[path] !== undefined) return asset[path];
			
			//アセットが取得できなかった場合、区切り文字を変換する
			path = TFPLoader.fixFilePath(path);
			
			//それでも取得できないならエラーを出す
			if (asset[path] === undefined)
			{
				throw new Error("[TFPHolder]アセットを取得できません。url=" + path);
			}
			
			return asset[path];
		}
		
		/**
		 * ファイルパスでXMLアセットを取得する。
		 * @param	path
		 * @return
		 */
		public function getXML(path:String):XML 
		{
			return getAsset(path);
		}
		
		/**
		 * ファイルパスでSoundアセットを取得する。
		 * @param	path
		 * @return
		 */
		public function getSound(path:String):Sound 
		{
			return getAsset(path);
		}
		
		/**
		 * ファイルパスでBitmapDataアセットを取得する。
		 * @param	path
		 * @return
		 */
		public function getBitmapData(path:String):BitmapData
		{
			return getAsset(path);
		}
		
		/**
		 * ファイルパスでStringアセットを取得する。
		 * @param	path
		 * @return
		 */
		public function getString(path:String):String 
		{
			return getAsset(path);
		}
		
		/**
		 * ファイルパスでByteArrayアセットを取得する。
		 * @param	path
		 * @return
		 */
		public function getByteArray(path:String):ByteArray 
		{
			return getAsset(path);
		}
		
		//--------------------------------------------------------------------------
		//
		//  情報の取得
		//
		//--------------------------------------------------------------------------
		
		/**
		 * アセットの総数を求める
		 * @return
		 */
		public function getAssetNum():int
		{
			var count:int = 0;
			for (var k:String in asset) count++;
			return count;
		}
		
		/**
		 * 全てのファイルパスのリストを求める
		 * @return
		 */
		public function getPathList():Vector.<String>
		{
			var list:Vector.<String> = new Vector.<String>;
			for (var k:String in asset) list.push(k);
			return list;
		}
		
		//--------------------------------------------------------------------------
		//
		//  結合
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 他のTFPHolderが持つアセットをこのTFPHolderに統合する。
		 * @param	tfp
		 */
		public function attach(holder:TFPHolder):void
		{
			for (var k:String in holder.asset)
			{
				asset[k] = holder.asset[k];
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  検索
		//
		//--------------------------------------------------------------------------
		
		/**
		 * ファイル名でアセットを検索し、一致するファイルパスを配列で返す。
		 * @param	fileName
		 * @return
		 */
		public function searchPath(fileName:String):Vector.<String>
		{
			var results:Vector.<String> = new Vector.<String>;
			for (var k:String in asset)
			{
				if (k.split("/").pop() == fileName)
				{
					results.push(k);
				}
			}
			return results;
		}
		
		/**
		 * 素材が存在するかチェック
		 * @param	path
		 */
		public function exists(path:String):Boolean 
		{
			return (asset[TFPLoader.fixFilePath(path)] !== undefined);
		}
		
		public function getAllAssetPath():Vector.<String> 
		{
			var result:Vector.<String> = new Vector.<String>;
			for (var key:String in asset)
			{
				result.push(key);
			}
			return result;
		}
		
		/**
		 * ￥を/に変換
		 * @param	path
		 * @return
		 */
		static private function correctPath(path:String):String
		{
			if (path.indexOf("\\") == -1) return path;
			return path.split("\\").join("/");
		}
		
	}

}