package net.morocoshi.moja3d.loader.exporters 
{
	import net.morocoshi.common.loaders.collada.ColladaParseOption;
	/**
	 * M3D書き出し時の設定
	 * 
	 * @author tencho
	 */
	public class M3DExportOption 
	{
		public var exportModel:Boolean = true;
		public var exportAnimation:Boolean = false;
		public var exportImage:Boolean = true;
		public var exportTangent4:Boolean = true;
		public var exportVertexColor:Boolean = true;
		public var exportUV:Boolean = true;
		
		/**カメラを書き出す*/
		public var exportCamera:Boolean = false;
		/**ライトを書き出す*/
		public var exportLight:Boolean = false;
		/**透過マップを書き出す*/
		public var exportTransparent:Boolean = true;
		/**ノーマルマップを書き出す*/
		public var exportNormal:Boolean = false;
		/**反射マップを書き出す*/
		public var exportReflection:Boolean = false;
		/**透過PNGのふちを修正する*/
		public var fixImage:Boolean = false;
		/**透過PNGのふちを修正する際の閾値[0x00-0xff]*/
		public var fixImageThreshold:uint = 0x80;
		
		/**FBXオブジェクトの追加プロパティをユーザーデータとして抽出するか*/
		public var extractObjectParam:Boolean = true;
		/**追加プロパティをユーザーデータとして抽出する時のプロパティ名リスト*/
		public var objectParamList:Array = [];
		
		/**非表示レイヤーを書き出す*/
		public var useHideLayer:Boolean = false;
		/**フリーズレイヤーを書き出す*/
		public var useFreezeLayer:Boolean = true;
		
		/**空のObjectは削除する*/
		public var deleteEmptyObject:Boolean = true;
		/***/
		public var lockUserPropertyObject:Boolean = true;
		/**小数点の精度を下げる*/
		public var lowVertices:Boolean = false;
		/**小数精度を下げる場合小数点第何位まで使うか*/
		public var lowNumber:int = 4;
		/**マテリアルパスのフォルダを削るか*/
		public var removeDirectory:Boolean = false;
		/**基点をオブジェクトのAABBの中心に動かす*/
		public var moveBasePoint:Boolean = false;
		/**ユーザープロパティのvisible=falseで非表示にする*/
		public var useVisible:Boolean = false;
		/**ユーザープロパティのshow=falseで非表示にする*/
		public var useShow:Boolean = false;
		/**マテリアルのリピート設定をUVから自動判別*/
		public var autoRepeat:Boolean = true;
		/**ルート階層へ動かせるオブジェクトは全て動かす*/
		public var moveToRoot:Boolean = true;
		/**同一マテリアルのサーフェイスを統合して最適化する*/
		public var optimizeSurface:Boolean = true;
		/***/
		public var ignoreUserDaraList:Array = [];
		
		/**TANGENT4の情報を削減する*/
		//public var deleteTangent4:Boolean = false;
		//public var deleteNormal:Boolean = false;
		//public var deleteUV:Boolean = false;
		//public var deleteVertexColor:Boolean = false;
		
		/**同一頂点でTangent4が違っても新しく頂点を生成しない。サイズがかなり減るが、色々と表示がおかしくなる可能性*/
		//public var simpleTangent4:Boolean = false;
		/**不透明マップの設定を書き出さない*/
		///public var ignoreTransparent:Boolean = false;
		
		public function M3DExportOption() 
		{
		}
		
		public function toColladaOption():ColladaParseOption 
		{
			var result:ColladaParseOption = new ColladaParseOption();
			result.exportAnimation = exportAnimation;
			result.exportCamera = exportCamera;
			result.exportLight = exportLight;
			result.exportModel = exportModel;
			result.exportNormal = exportNormal;
			result.exportTangent4 = exportTangent4;
			
			return result;
		}
		
	}

}