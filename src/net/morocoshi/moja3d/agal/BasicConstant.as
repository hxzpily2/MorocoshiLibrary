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
		public var cameraPosition:AGALConstant;
		public var viewSize:AGALConstant;
		public var ambient:AGALConstant;
		public var number:AGALConstant;
		public var reflectionMap:AGALTexture;
		
		static public const MODEL_MATRIX:String = "@modelMatrix";
		static public const VIEW_MATRIX:String = "@viewMatrix";
		static public const PROJ_MATRIX:String = "@projMatrix";
		static public const CAMERA_POSITION:String = "@cameraPosition";
		static public const VIEW_SIZE:String = "@viewSize";
		static public const AMBIENT_COLOR:String = "@ambientColor";
		static public const CLIPPING:String = "@clipping";
		static public const NUMBER:String = "@number";
		
		public function BasicConstant(code:AGALCode) 
		{
			modelMatrix = code.addConstantsFromMatrix(MODEL_MATRIX, null, true);
			viewMatrix = code.addConstantsFromMatrix(VIEW_MATRIX, null, true);
			projMatrix = code.addConstantsFromMatrix(PROJ_MATRIX, null, true);
			cameraPosition = code.addConstantsFromVector3D(CAMERA_POSITION, null);
			clipping = code.addConstantsFromVector3D(CLIPPING, null);
			viewSize = code.addConstantsFromVector3D(VIEW_SIZE, null);
			ambient = code.addConstantsFromColor(AMBIENT_COLOR, 0x000000, 1);
			number = code.addConstantsFromArray(NUMBER, [0, 0.5, 1, 2]);
		}
		
		public function apply(using:UsingConstants):void
		{
			clipping.enabled = using.clipping;
			cameraPosition.enabled = using.cameraPosition;
			modelMatrix.enabled = using.modelMatrix;
			projMatrix.enabled = using.projMatrix;
			viewMatrix.enabled = using.viewMatrix;
			viewSize.enabled = using.viewSize;
			ambient.enabled = using.ambient;
			number.enabled = using.number;
		}
		
	}

}