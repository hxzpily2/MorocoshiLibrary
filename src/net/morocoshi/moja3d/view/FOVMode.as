package net.morocoshi.moja3d.view 
{
	/**
	 * ...
	 * @author tencho
	 */
	public class FOVMode 
	{
		/**
		 * カメラは縦方向のFOVを使用します。Camera3D.fovYの値を使用します。デフォルトはこれです。
		 */
		static public const VERTICAL:String = "vertical";
		/**
		 * カメラは横方向のFOVを使用します。Camera3D.fovXの値を使用します。
		 */
		static public const HOLIZONTAL:String = "horizontal";
		/**
		 * カメラは縦横両方のFOVを使用します。常にFOVの領域外がビューポートに映らないように調整されます。Camera3D.fovX/fovY両方の値を使用します。
		 */
		static public const CIRCUMSCRIBED:String = "circumscribed";
		/**
		 * カメラは縦横両方のFOVを使用します。常にFOVの領域内がビューポートに収まるように調整されます。Camera3D.fovX/fovY両方の値を使用します。
		 */
		static public const INSCRIBED:String = "inscribed";
		
		public function FOVMode() 
		{
		}
		
	}

}