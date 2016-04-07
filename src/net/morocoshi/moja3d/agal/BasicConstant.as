package net.morocoshi.moja3d.agal 
{
	import net.morocoshi.moja3d.agal.UsingConstants;
	
	/**
	 * 多くのシェーダーで使う共通の定数レジスタを管理
	 * 
	 * @author tencho
	 */
	public class BasicConstant 
	{
		public var clipping:AGALConstant;
		public var modelMatrix:AGALConstant;
		public var viewMatrix:AGALConstant;
		public var projMatrix:AGALConstant;
		public var clipMatrix:AGALConstant;
		/**XYZがカメラのワールド座標。Wはビューサイズに関係なく一定のサイズにできるようにする係数*/
		public var cameraPosition:AGALConstant;
		/**カメラのワールド空間における正面ベクトル*/
		public var cameraDirection:AGALConstant;
		/**XYがクリッピングを無視したビューポートサイズ。ZWがクリッピングを考慮したビューポートサイズ*/
		public var viewSize:AGALConstant;
		public var ambient:AGALConstant;
		public var number:AGALConstant;
		//public var reflectionMap:AGALTexture;
		
		static public const MODEL_MATRIX:String = "@modelMatrix";
		static public const VIEW_MATRIX:String = "@viewMatrix";
		static public const PROJ_MATRIX:String = "@projMatrix";
		static public const CLIP_MATRIX:String = "@clipMatrix";
		static public const CAMERA_POSITION:String = "@cameraPosition";
		static public const CAMERA_DIRECTION:String = "@cameraDirection";
		static public const VIEW_SIZE:String = "@viewSize";
		static public const AMBIENT_COLOR:String = "@ambientColor";
		static public const CLIPPING:String = "@clipping";
		static public const NUMBER:String = "@number";
		
		public function BasicConstant(code:AGALCode) 
		{
			modelMatrix = code.addConstantsFromMatrix(MODEL_MATRIX, null, true);
			viewMatrix = code.addConstantsFromMatrix(VIEW_MATRIX, null, true);
			projMatrix = code.addConstantsFromMatrix(PROJ_MATRIX, null, true);
			clipMatrix = code.addConstantsFromMatrix(CLIP_MATRIX, null, true);
			cameraPosition = code.addConstantsFromVector3D(CAMERA_POSITION, null);
			cameraDirection = code.addConstantsFromVector3D(CAMERA_DIRECTION, null);
			clipping = code.addConstantsFromVector3D(CLIPPING, null);
			viewSize = code.addConstantsFromVector3D(VIEW_SIZE, null);
			ambient = code.addConstantsFromColor(AMBIENT_COLOR, 0x000000, 1);
			number = code.addConstantsFromArray(NUMBER, [0, 0.5, 1, 2]);
		}
		
		public function apply(using:UsingConstants):void
		{
			clipping.enabled = using.clipping;
			cameraPosition.enabled = using.cameraPosition;
			cameraDirection.enabled = using.cameraDirection;
			modelMatrix.enabled = using.modelMatrix;
			projMatrix.enabled = using.projMatrix;
			clipMatrix.enabled = using.clipMatrix;
			viewMatrix.enabled = using.viewMatrix;
			viewSize.enabled = using.viewSize;
			ambient.enabled = using.ambient;
			number.enabled = using.number;
		}
		
		public function dispose():void 
		{
			modelMatrix.dispose();
			viewMatrix.dispose();
			projMatrix.dispose();
			clipMatrix.dispose();
			cameraPosition.dispose();
			cameraDirection.dispose();
			clipping.dispose();
			viewSize.dispose();
			ambient.dispose();
			number.dispose();
			
			modelMatrix = null;
			viewMatrix = null;
			projMatrix = null;
			clipMatrix = null;
			cameraPosition = null;
			cameraDirection = null;
			clipping = null;
			viewSize = null;
			ambient = null;
			number = null;
		}
		
	}

}