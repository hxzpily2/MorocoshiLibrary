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
		public var exportAnimation:Boolean = true;
		public var exportImage:Boolean = true;
		public var exportTangent4:Boolean = true;
		public var exportVertexColor:Boolean = true;
		public var exportUV:Boolean = true;
		
		/**カメラを書き出す*/
		public var exportCamera:Boolean = false;
		/**ライトを書き出す*/
		public var exportLight:Boolean = false;
		/**不透明マップを書き出す*/
		public var exportTransparent:Boolean = true;
		/**数値による不透明情報を書き出す*/
		public var exportAlpha:Boolean = true;
		/**ノーマルマップを書き出す*/
		public var exportNormal:Boolean = true;
		/**反射マップを書き出す*/
		public var exportReflection:Boolean = false;
		/**透過PNGのふちを修正する*/
		public var fixImageEnabled:Boolean = false;
		/**透過PNGのふちを修正する際の閾値[0x00-0xff]*/
		public var fixImageThreshold:uint = 0x80;
		/**MAXから書き出した時によくある、diffuseとopacity両方に同じPNG画像が貼られていた場合にopacityを無視する*/
		public var fixMaxStylePngTexture:Boolean = true;
		/**画像出力時、可能なものはJPGに変換する*/
		public var convertJpgEnabled:Boolean = true;
		/**JPG化する際の画質設定*/
		public var convertJpgQuality:uint = 90;
		
		/**FBXオブジェクトの追加プロパティをユーザーデータとして抽出するか*/
		public var extractObjectParam:Boolean = true;
		/**追加プロパティをユーザーデータとして抽出する時のプロパティ名リスト*/
		public var objectParamList:Array = [];
		
		/**非表示レイヤーを書き出す*/
		public var useHideLayer:Boolean = true;
		/**フリーズレイヤーを書き出す*/
		public var useFreezeLayer:Boolean = true;
		
		/**空のObjectは削除する*/
		public var deleteEmptyObject:Boolean = true;
		/**スキン内部の空っぽオブジェクトは削除しない*/
		public var lockSkinEmptyObject:Boolean = true;
		/**ユーザープロパティをもつ空っぽオブジェクトは削除しない*/
		public var lockUserPropertyObject:Boolean = true;
		/**マテリアルパスのフォルダを削るか*/
		public var removeDirectory:Boolean = true;
		/**基点をオブジェクトのAABBの中心に動かす*/
		public var moveBasePoint:Boolean = false;
		/**ユーザープロパティのvisible=falseで非表示にする*/
		public var useVisible:Boolean = false;
		/**ユーザープロパティのshow=falseで非表示にする*/
		public var useShow:Boolean = false;
		/**マテリアルのリピート設定をUVから自動判別*/
		public var autoRepeat:Boolean = false;
		/**ルート階層へ動かせるオブジェクトは全て動かす*/
		public var moveToRoot:Boolean = false;
		/**同一マテリアルのサーフェイスを統合して最適化する*/
		public var optimizeSurface:Boolean = false;
		/**基点移動で発生したメッシュのネスト化を解除する*/
		public var mergeNestedMesh:Boolean = false;
		/**1つのスキンメッシュが持てるボーン数の限界数（これを超えた部分は分割される）*/
		public var boneLimit:int = 20;
		/**ウェイトの数を最大4つにする*/
		public var halfWeight:Boolean = false;
		
		/***/
		public var ignoreUserDataList:Array = [];
		
		
		/**小数点の精度を下げる*/
		public var lowVertices:Boolean = false;
		/**小数精度を下げる場合小数点第何位まで使うか*/
		public var lowNumber:int = 4;
		/**同一頂点でTangent4が違っても新しく頂点を生成しない。サイズがかなり減るが、色々と表示がおかしくなる可能性*/
		//public var simpleTangent4:Boolean = false;
		
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
			result.halfWeight = halfWeight;
			result.mergeNestedMesh = mergeNestedMesh;
			
			return result;
		}
		
	}

}